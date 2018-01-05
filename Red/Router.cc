//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

#include "Router.h"
#include "Paquetes/Transporte_m.h"

Router::Router() {
    // TODO Auto-generated constructor stub
    routes = NULL;
    n_routes = 0;
    header_tam = 0;
    direccion = 0;
    destino = 0;
    down_inc = 0;
    down_outc = 0;
    up_inc = 0;
    up_outc = 0;
    ttl = 0;
}

Router::~Router() {
    // TODO Auto-generated destructor stub
    delete[] routes;
}

void Router::initialize() {
    for (int i = 0; i < max_gates; i++) {
        if (gate("up_in", i)->isConnected()) {
            up_in[i] = true;
            up_inc++;
        } else {
            up_in[i] = false;
        }

        if (gate("up_out", i)->isConnected()) {
            up_out[i] = true;
            up_outc++;
        } else {
            up_out[i] = false;
        }

        if (gate("down_in", i)->isConnected()) {
            down_in[i] = true;
            down_inc++;
        } else {
            down_in[i] = false;
        }

        if (gate("down_out", i)->isConnected()) {
            down_out[i] = true;
            down_outc++;
        } else {
            down_out[i] = false;
        }
    }

    header_tam = par("header_tam");
    direccion = par("direccion");
    ttl = par("ttl");

    if (par("destino").containsValue()
            && ((destino = par("destino")) < min_net || destino > max_net)) {
        bubble("Destino no valido");
        abort();
    }

    if (!par("configuracion").containsValue()
            || (n_routes = config(par("configuracion").xmlValue())) < 0) {
        bubble("Configuracion no valida");
        abort();
    }

}

void Router::handleMessage(cMessage* msg) {

    Red* red = NULL;

    if (msg->arrivedOn("up_in")) { //Viene de arriba
        char nombre[15];
        sprintf(nombre, "Red-%d", ((Transporte*) msg)->getSecuencia());

        red = new Red(nombre);

        red->setSrcAddr(direccion);
        red->setDstAddr(destino);
        red->setTtl(ttl);
        red->setBitLength(header_tam);
        red->encapsulate((cPacket*) msg);

        rutar(red);

    } else { //Viene de abajo

        red = (Red *) msg;

        if (red->hasBitError()) { //Si el paquete tiene errores directamente descartar
            bubble("Paquete con error");
            delete (msg);
        } else {
            int dest = red->getDstAddr();

            if (dest == direccion) {
                /*soy el destinatario*/
                send_up(red);
            } else {
                /*necesario rutar*/
                if (red->getTtl() == 1) {

                    bubble("Paquete con TTL a 0");
                    delete (red);
                } else {
                    red->setTtl(red->getTtl() - 1);
                    rutar(red);
                }
            }
        }
    }
}

int Router::config(cXMLElement *xml) {
    cXMLElement *tmp;
    cXMLElement *gate_tmp;
    int n = 1;
    int i = 0;
    int ng = 1;
    int ig = 0;

    if (strcmp(xml->getTagName(), "routes") != 0) {
        /*no es el tipo esperado*/
        EV << "XML inesperado";
        return -1;
    }

    if (not (xml->hasChildren())) {
        /*no contine rutas*/
        EV << "No hay rutas";
        return -1;
    }

    /*comprobar número de rutas*/
    tmp = xml->getFirstChild();
    if (not (tmp->hasChildren())) {
        EV << "Una ruta no tiene puertas";
        return -1;
    }

    while ((tmp = tmp->getNextSibling()) != NULL) {
        n++;
        if (not (tmp->hasChildren())) {
            EV << "Una ruta no tiene puertas";
            return -1;
        }
    }

    routes = new route[n];

    tmp = xml->getFirstChild();

    for (i = 0; i < n; i++, tmp = tmp->getNextSibling()) {

        gate_tmp = tmp->getFirstChild();
        ng = 1;
        while ((gate_tmp = gate_tmp->getNextSibling()) != NULL) {
            ng++;
        }

        routes[i].start = atoi(tmp->getAttribute("start"));
        routes[i].stop = atoi(tmp->getAttribute("stop"));

        if (routes[i].start < min_net || routes[i].start > max_net
                || routes[i].stop < min_net || routes[i].stop > max_net) {
            EV << "Rango de direcciones erroneo";
            return -1;
        }
        if (routes[i].start > routes[i].stop) {
            EV << "Start mayor que Stop";
            return -1;
        }

        routes[i].gates = new output[ng];
        routes[i].n_gates = ng;

        double p;
        gate_tmp = tmp->getFirstChild();
        for (ig = 0, p = 0; ig < ng;
                ig++, gate_tmp = gate_tmp->getNextSibling()) {
            routes[i].gates[ig].gate = atoi(gate_tmp->getAttribute("id"));
            if (routes[i].gates[ig].gate >= max_gates) {
                EV << "Solo hay " << max_gates << " salidas";
                return -1;
            }
            if (not (down_out[routes[i].gates[ig].gate])) {
                EV << "Puerta no conectada " << routes[i].gates[ig].gate;
                return -1;
            }

            if (gate_tmp->getAttribute("prob") != NULL) {
                routes[i].gates[ig].prob = atof(gate_tmp->getAttribute("prob"));
                if (routes[i].gates[ig].prob > 1
                        || routes[i].gates[ig].prob <= 0) {
                    EV << "Probabilidad erronea";
                    return -1;
                }
                p += routes[i].gates[ig].prob;
            }

        }

        if (routes[i].n_gates > 1 && p != 1) {
            EV << "Error en la suma de probabilidades: " << p << " n_gates:"
                      << routes[i].n_gates;
            return -1;
        }
    }

    return n;
}

void Router::rutar(Red* red) {

    double irand, crand;
    unsigned int dest = red->getDstAddr();

    for (int i = 0; i < n_routes; i++) {
        if (dest >= routes[i].start && dest <= routes[i].stop) {
            if (routes[i].n_gates == 1) {
                send(red, "down_out", routes[i].gates[0].gate);
                return;
            } else {
                irand = uniform(0, 1);
                crand = 0;
                for (int j = 0; j < routes[i].n_gates; j++) {
                    if (irand < (crand += routes[i].gates[j].prob)) {
                        send(red, "down_out", routes[i].gates[j].gate);
                        return;
                    }
                }
            }
        }
    }
}

void Router::send_up(Red* red) {
/*
    Transport * tp = (Transport *) nw->decapsulate();
    int gate = tp->getDstAddr();
    if (gate < min_trans || gate > max_trans) {
        bubble("puerto erroneo");
        delete (tp);
        return;
    } else {
        gate = gate / 100;
        il->setOrigen(nw->getSrcAddr());
        il->setDestino(origen);
        il->encapsulate(tp);
        send(il, "up_out", gate);
    }
    */
}

