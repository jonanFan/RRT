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
#include "Paquetes/InterTransporteRed_m.h"

Router::Router() {
    // TODO Auto-generated constructor stub
    routes = NULL;
    n_routes = 0;
    header_tam = 0;
    direccion = 0;
    destino = 0;

    ttl = 0;
}

Router::~Router() {
    // TODO Auto-generated destructor stub
    delete[] routes;
    for (int i = 0; i < max_gates; i++) {
        if (down_gates[i].txQueue != nullptr) {
            down_gates[i].txQueue->~cQueue();
            cancelAndDelete(down_gates[i].enviado);
        }
    }
}

void Router::initialize() {
    for (int i = 0; i < max_gates; i++) {
        initializeGate(&(up_gates[i]));
        initializeGate(&(down_gates[i]));

        if (gate("up_layer$i", i)->isConnected()) {
            up_gates[i].input = true;
        }

        if (gate("up_layer$o", i)->isConnected()) {
            up_gates[i].output = true;
        }

        if (gate("down_layer$i", i)->isConnected()) {
            down_gates[i].input = true;
        }

        if (gate("down_layer$o", i)->isConnected()) {
            down_gates[i].output = true;
            if (gate("down_layer$o", i)->findTransmissionChannel() != nullptr) {
                down_gates[i].txChannel =
                        gate("down_layer$o", i)->findTransmissionChannel();
                down_gates[i].txQueue = new cQueue();
                down_gates[i].enviado = new PaqueteEnviado();
                down_gates[i].enviado->setGateId(i);
            }
        }
    }

    header_tam = par("redHeaderTam");
    ttl = par("TTL");

    if (((direccion = par("direccion")) < min_net || destino > max_net)) {
        EV << "Direccion no valido\n";
        endSimulation();
    }

    destino = par("destino");

    /*if (par("destino").containsValue()
     && ((destino = par("destino")) < min_net || destino > max_net)) {
     EV << "Destino no valido\n";
     endSimulation();
     }*/

    if (!par("configuracion").containsValue()
            || (n_routes = config(par("configuracion").xmlValue())) < 0) {
        EV << "Configuracion no valida\n";
        endSimulation();
    }

}

void Router::initializeGate(gates* gateInit) {
    gateInit->input = false;
    gateInit->output = false;
    gateInit->txChannel = nullptr;
    gateInit->txQueue = nullptr;
    gateInit->enviado = nullptr;
}

void Router::handleMessage(cMessage* msg) {

    Red* red = NULL;

    if (msg->isSelfMessage()) {
        PaqueteEnviado* eventoEnviar = check_and_cast<PaqueteEnviado *>(msg);
        gates* selected_gate = &down_gates[eventoEnviar->getGateId()];

        red = (Red*) selected_gate->txQueue->pop();

        send(red, "down_layer$o", eventoEnviar->getGateId());

        if (!selected_gate->txQueue->isEmpty())
            scheduleAt(selected_gate->txChannel->getTransmissionFinishTime(),
                    selected_gate->enviado);
    } else if (msg->arrivedOn("up_layer$i")) { //Viene de arriba

        InterTransporteRed* itr = check_and_cast<InterTransporteRed *>(msg);
        Transporte* transporte = check_and_cast<Transporte *>(
                itr->decapsulate());

        unsigned int origen;

        if (((origen = itr->getOrigen()) == 0 && itr->getDestino() == 0
                && destino != 0) || (origen != 0 && itr->getDestino() != 0)) {
            char nombre[20];
            sprintf(nombre, (origen == 0 ? "RedReq-%d" : "RedRes-%d"),
                    transporte->getSecuencia());

            red = new Red(nombre);

            if (origen == 0) { //Nuevo paquete
                red->setSrcAddr(direccion);
                red->setDstAddr(destino);
            } else { //Respuesta a un paquete
                red->setSrcAddr(itr->getDestino());
                red->setDstAddr(itr->getOrigen());
            }

            red->setTtl(ttl);
            red->setBitLength(header_tam);
            red->encapsulate(transporte);

            if (direccion != destino) {
                rutar(red);
            } else { //Cosa un poco raro, pero contemplado
                send_up(red);
            }
        } else {
            EV
                      << "Ha llegado un paquete de la capa de arriba en malas condiciones\n";
            delete (transporte);

        }

        delete (itr);
    } else { //Viene de abajo

        red = (Red *) msg;

        if (red->hasBitError()) { //Si el paquete tiene errores directamente descartar
            EV << "Recibido paquete con error\n";
            delete (msg);
        } else {
            int destino = red->getDstAddr();

            if (destino == direccion) {
                /*soy el destinatario*/
                send_up(red);
            } else {
                /*necesario rutar*/
                if (red->getTtl() == 1) {

                    EV << "Paquete con TTL a 0\n";
                    delete (red);
                } else {
                    red->setTtl(red->getTtl() - 1);
                    rutar(red);
                }
            }
        }
    }
}

void Router::rutar(Red* red) {

    simtime_t time;
    gates* selected_gate;
    double irand, crand;
    unsigned int dest = red->getDstAddr();

    for (int i = 0; i < n_routes; i++) {
        if (dest >= routes[i].start && dest <= routes[i].stop) {
            if (routes[i].n_gates == 1) {
                if (gate("down_layer$o", routes[i].gates[0].gate)->isConnected()) {
                    selected_gate = &down_gates[routes[i].gates[0].gate];
                    if (selected_gate->txChannel != nullptr) { //Tenemos un canal

                        selected_gate->txQueue->insert(red);

                        if (!selected_gate->enviado->isScheduled()) {
                            time = simTime();
                            if (time
                                    < selected_gate->txChannel->getTransmissionFinishTime())
                                time =
                                        selected_gate->txChannel->getTransmissionFinishTime();

                            scheduleAt(time, selected_gate->enviado);
                        }
                    } else
                        //El enlace esta enchufado directo sin canal ninguno
                        send(red, "down_layer$o", routes[i].gates[0].gate);
                } else
                    delete (red);
                return;
            } else {
                irand = uniform(0, 1);
                crand = 0;
                for (int j = 0; j < routes[i].n_gates; j++) {
                    if (irand < (crand += routes[i].gates[j].prob)) {
                        if (gate("down_layer$o", routes[i].gates[j].gate)->isConnected()) {
                            selected_gate =
                                    &down_gates[routes[i].gates[j].gate];
                            if (selected_gate->txChannel != nullptr) { //Tenemos un canal

                                selected_gate->txQueue->insert(red);

                                if (!selected_gate->enviado->isScheduled()) {
                                    time = simTime();
                                    if (time
                                            < selected_gate->txChannel->getTransmissionFinishTime())
                                        time =
                                                selected_gate->txChannel->getTransmissionFinishTime();

                                    scheduleAt(time, selected_gate->enviado);
                                }
                            } else
                                //El enlace esta enchufado directo sin canal ninguno
                                send(red, "down_layer$o",
                                        routes[i].gates[j].gate);
                        } else
                            delete (red);
                        return;
                    }
                }
            }
        }
    }

    delete (red);
}

void Router::send_up(Red* red) {

    Transporte * transporte = (Transporte *) red->decapsulate();
    int puerto = transporte->getDstPort();

    if (puerto >= max_gates || !gate("up_layer$o", puerto)->isConnected()) {
        EV
                  << "Recibido paquete hacia un puerto en el que no hay capa de transporte\n";
        delete (transporte);
    } else {

        InterTransporteRed* itr = new InterTransporteRed(transporte->getName());
        itr->setOrigen(red->getSrcAddr());
        itr->setDestino(red->getDstAddr());
        itr->encapsulate(transporte);

        send(itr, "up_layer$o", puerto);
    }
    delete (red);
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
        EV << "XML inesperado\n";
        return -1;
    }

    if (not (xml->hasChildren())) {
        /*no contine rutas*/
        EV << "No hay rutas\n";
        return -1;
    }

    /*comprobar número de rutas*/
    tmp = xml->getFirstChild();
    if (not (tmp->hasChildren())) {
        EV << "Una ruta no tiene puertas\n";
        return -1;
    }

    while ((tmp = tmp->getNextSibling()) != NULL) {
        n++;
        if (not (tmp->hasChildren())) {
            EV << "Una ruta no tiene puertas\n";
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
            EV << "Rango de direcciones erroneo\n";
            return -1;
        }
        if (routes[i].start > routes[i].stop) {
            EV << "Ruta de inicio mayor que la ruta de fin\n";
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
                EV << "Solo hay " << max_gates << " salidas\n";
                return -1;
            }
            if (not (down_gates[routes[i].gates[ig].gate].output)) {
                EV << "Puerta no conectada " << routes[i].gates[ig].gate
                          << "\n";
                return -1;
            }

            if (gate_tmp->getAttribute("prob") != NULL) {
                routes[i].gates[ig].prob = atof(gate_tmp->getAttribute("prob"));
                if (routes[i].gates[ig].prob > 1
                        || routes[i].gates[ig].prob <= 0) {
                    EV
                              << "Probabilidad erronea, deberia ser un valor entre 0 y 1\n";
                    return -1;
                }
                p += routes[i].gates[ig].prob;
            }

        }

        if (routes[i].n_gates > 1 && p != 1) {
            EV << "Error en la suma de probabilidades: " << p << " n_gates:"
                      << routes[i].n_gates << "\n";
            return -1;
        }
    }

    return n;
}
