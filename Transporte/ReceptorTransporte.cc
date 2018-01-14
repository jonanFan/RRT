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
#include "Paquetes/InterTransporteRed_m.h"
#include "Paquetes/General.h"
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
    answerAck = par("answerAck");

    if (puerto >= max_gates) {
        EV << "Puerto maximo excedido\n";
        endSimulation();
    }
}

void ReceptorTransporte::handleMessage(cMessage *msg) {

    InterTransporteRed* itrPeticion = check_and_cast<InterTransporteRed *>(msg);
    Transporte* peticion = check_and_cast<Transporte *>(
            itrPeticion->decapsulate());

    char *nombre = (char*) peticion->getName();

    if (itrPeticion->getPacketType() == packet_request
            && peticion->getDstPort() == puerto) {

        Transporte* respuesta = generarRespuesta(peticion);

        InterTransporteRed* itrRespuesta = new InterTransporteRed(
                respuesta->getName());
        itrRespuesta->setOrigen(itrPeticion->getOrigen());
        itrRespuesta->setDestino(itrPeticion->getDestino());
        itrRespuesta->setPacketType(packet_response);
        itrRespuesta->encapsulate(respuesta);

        if (respuesta->getAck() == 1) {

           // EV << "SIMTIME PETICION " << peticion->getTimestamp() << "\n";
            simtime_t time = simTime() - peticion->getTimestamp();
            paqueteTimeVector.record(time);
            paqueteTimeStat.collect(time);

            send(peticion->decapsulate(), "up_layer");
        }

        if (answerAck == true)
            send(itrRespuesta, "down_layer$o");
        else {
            delete (itrRespuesta);
            //delete (respuesta);
        }
    } else if (itrPeticion->getPacketType() == packet_send) {

    } else
        EV << "Paquete de tipo desconocido\n";

    delete (peticion);
    delete (itrPeticion);
}

Transporte* ReceptorTransporte::generarRespuesta(Transporte* peticion) {
    char nombre[15];
    unsigned int secuencia = peticion->getSecuencia();

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

void ReceptorTransporte::refreshDisplay() const {
    char buf[40];

    sprintf(buf, "Mean: %.2lf ms", paqueteTimeStat.getMean());

    getDisplayString().setTagArg("t", 0, buf);
}

