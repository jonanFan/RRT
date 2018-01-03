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

ReceptorTransporte::ReceptorTransporte() {
    // TODO Auto-generated constructor stub
    txQueue = NULL;
    this->enviarMensajeEvento = new cMessage();
    this->probAckLoss = 0;
    this->probPacketLoss = 0;
    this->lenAck = 0;
}

ReceptorTransporte::~ReceptorTransporte() {
    // TODO Auto-generated destructor stub
    if (txQueue != NULL)
        txQueue->~cQueue();

    cancelAndDelete(enviarMensajeEvento);

}

void ReceptorTransporte::initialize() {
    txChannel = gate("receiver$o")->getTransmissionChannel();
    txQueue = new cQueue();
    this->probAckLoss = par("probACKLoss");
    this->probPacketLoss = par("probPacketLoss");
    this->lenAck = par("lenACK");
}

void ReceptorTransporte::handleMessage(cMessage *msg) {
    Transporte* pkt = NULL;

    if (msg == enviarMensajeEvento) {
        pkt = (Transporte*) txQueue->pop();
        if (uniform(0, 1) >= probAckLoss) {
            send(pkt, "receiver$o");
            //EV << "ReceptorTransporte: SACO DE LA COLA";
            if (!txQueue->isEmpty()) {
                scheduleAt(txChannel->getTransmissionFinishTime(),
                        enviarMensajeEvento);
            }
        } else {
            EV << "ReceptorTransporte: "<< pkt->getName() << " PERDIDO\n";

            if (!txQueue->isEmpty()) {
                scheduleAt(simTime(), enviarMensajeEvento);
            }

            delete(pkt);
        }
    } else {
        pkt = check_and_cast<Transporte *>(msg);

        if (uniform(0, 1) >= probPacketLoss) {
            Transporte* Transporte = generarPaquete(pkt->hasBitError() ? 1 : 0,
                    pkt->getSecuencia(), pkt->getTimestamp());
            if (txQueue->isEmpty()) {
                simtime_t timer = 0;

                if (simTime() >= txChannel->getTransmissionFinishTime())
                    timer = simTime();
                else
                    timer = txChannel->getTransmissionFinishTime();
                scheduleAt(timer, enviarMensajeEvento);
            }
            //EV << "\nReceptorTransporte: INSERTO EN COLA\n";
            txQueue->insert(Transporte);
        } else {
            EV << "ReceptorTransporte: "<< pkt->getName() << " PERDIDO\n";
        }

        delete (pkt);
    }
}

Transporte* ReceptorTransporte::generarPaquete(int error, unsigned int secuencia, simtime_t timestamp) {
    char nombre[15];

    if (error == 1) {
        sprintf(nombre, "NACK-%d", secuencia);
        EV << "ReceptorTransporte: ENVIANDO NACK-" << secuencia << "\n";
    } else {
        sprintf(nombre, "ACK-%d", secuencia);
        EV << "ReceptorTransporte: ENVIANDO ACK-" << secuencia << "\n";
    }

    Transporte* msg = new Transporte(nombre, 0);
    msg->setAck(!error);
    msg->setSecuencia(secuencia);
    msg->setBitLength(lenAck);
    msg->setTimestamp(timestamp);

    return msg;
}
