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

#include "TransmisorDummy.h"

#include "Paquetes/Transporte_m.h"
#include "Paquetes/InterTransporteRed_m.h"
#include <string.h>
#include <stdio.h>

TransmisorDummy::TransmisorDummy() {
    // TODO Auto-generated constructor stub
    header_tam = 0;
    puerto = 0;
    dstPuerto = 0;
}

TransmisorDummy::~TransmisorDummy() {
    // TODO Auto-generated destructor stub

}

void TransmisorDummy::initialize() {
    secuencia = 0;
    header_tam = par("transporteHeaderTam");
    puerto = par("puerto");
    dstPuerto = par("dstPuerto");

    if (puerto >= max_gates || dstPuerto >= max_gates) {
        EV << "Puerto maximo excedido\n" ;
        endSimulation();
    }
}

void TransmisorDummy::handleMessage(cMessage* msg) {

    Transporte* paquete = NULL;
    InterTransporteRed* itr= NULL;

    if (msg->arrivedOn("up_layer")) {
        char nombre[15];
        sprintf(nombre, "Transporte-%d", secuencia);
        paquete = new Transporte(nombre);
        paquete->setAck(-1);
        paquete->setSecuencia(secuencia++);
        paquete->setTimestamp(simTime());
        paquete->setBitLength(header_tam);
        paquete->setSrcPort(puerto);
        paquete->setDstPort(dstPuerto);
        paquete->encapsulate((cPacket*) msg);

        itr=new InterTransporteRed(nombre);
        itr->encapsulate(paquete);
        itr->setOrigen(0);
        itr->setDestino(0);
        send(itr, "down_layer$o");

    } else if (msg->arrivedOn("down_layer$i")) {

        itr=check_and_cast<InterTransporteRed *>(msg);
        paquete = check_and_cast<Transporte *>(itr->decapsulate());
        char* nombre = (char*) paquete->getName();

        if ((strncmp(nombre, "NACK", 4) == 0 || strncmp(nombre, "ACK", 3) == 0)
                && !paquete->hasBitError() && paquete->getDstPort() == puerto) {

            if (paquete->getAck() != -1 && paquete->getName())
                EV << "PAQUETE " << paquete->getName() << " RECIBIDO CON "
                          << (paquete->getAck() == 0 ? "NACK" : "ACK") << "\n";
            else {
                EV << "PAQUETE " << paquete->getName()
                          << " RECIBIDO NO ES UN ACK\n";
            }
        }
        delete (paquete);
        delete (itr);
    } else {
        delete (msg);
    }
}
