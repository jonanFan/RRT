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

#include "ReceptorTransporte.h"
#include <string.h>
#include <stdio.h>

ReceptorTransporte::ReceptorTransporte() {
    // TODO Auto-generated constructor stub
    lenAck = 0;
    puerto = 0;
}

ReceptorTransporte::~ReceptorTransporte() {
    // TODO Auto-generated destructor stub
}

void ReceptorTransporte::initialize() {
    lenAck = par("lenACK");
    puerto = par("puerto");
}

void ReceptorTransporte::handleMessage(cMessage *msg) {
    Transporte* peticion = check_and_cast<Transporte *>(msg);

    char *nombre=(char*)peticion->getName();

    if ((strncmp(nombre, "NACK", 4) != 0 || strncmp(nombre, "ACK", 3) != 0) && peticion->getDstPort() == puerto)
    {
        Transporte* respuesta = generarRespuesta(peticion);

        if(respuesta->getAck()==1)
        {
            send(peticion->decapsulate(), "up_layer");
        }

        send(respuesta, "down_layer$o");
    }

    delete (peticion);
}

Transporte* ReceptorTransporte::generarRespuesta(Transporte* peticion) {
    char nombre[15];
    unsigned int secuencia=peticion->getSecuencia();

    if (peticion->hasBitError()) {
        sprintf(nombre, "NACK-%d", secuencia);
        EV << "ReceptorTransporte: ENVIANDO NACK-" << secuencia << "\n";
    } else {
        sprintf(nombre, "ACK-%d", secuencia);
        EV << "ReceptorTransporte: ENVIANDO ACK-" << secuencia << "\n";
    }

    Transporte* msg = new Transporte(nombre, 0);
    msg->setAck(!peticion->hasBitError());
    msg->setSecuencia(secuencia);
    msg->setBitLength(lenAck);
    msg->setTimestamp(peticion->getTimestamp());
    msg->setSrcPort(puerto);
    msg->setDstPort(peticion->getSrcPort());

    return msg;
}
