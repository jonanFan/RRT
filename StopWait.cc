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

#include "StopWait.h"

StopWait::StopWait() {
    // TODO Auto-generated constructor stub
    txQueue = NULL;
    enviarMensajeEvento = new cMessage();
    timeoutEvento = new cMessage();
    setTimeoutEvento = new cMessage();
    mensajeEnviado = NULL;
    lenACK=0;
}

StopWait::~StopWait() {
    // TODO Auto-generated destructor stub
    if (txQueue != NULL)
        txQueue->~cQueue();

    cancelAndDelete(enviarMensajeEvento);
    cancelAndDelete(timeoutEvento);
    cancelAndDelete(setTimeoutEvento);

}

void StopWait::initialize() {
    txChannel = (cDatarateChannel*)gate("sender$o")->getTransmissionChannel();
    txQueue = new cQueue();
    lenACK=par("lenACK");
}

void StopWait::handleMessage(cMessage* msg) {

    Paquete* paquete = NULL;

    if (msg == enviarMensajeEvento) { //SCHEDULER QUE ENVIA LOS PAQUETES CUANDO TOCA
        paquete = (Paquete*) txQueue->pop();
        mensajeEnviado = paquete->dup();

        EV << "ENVIANDO MENSAJE " << mensajeEnviado->getName();
        send(paquete, "sender$o");

        scheduleAt(txChannel->getTransmissionFinishTime(),
                            setTimeoutEvento);

        //EV << "SW: SACO DE LA COLA\n";
        /*if (!txQueue->isEmpty()) {
         scheduleAt(txChannel->getTransmissionFinishTime(), enviarMensajeEvento);
         }*/
    } else if (msg == timeoutEvento) { //HA SALTADO EL TIMEOUT DE QUE NO SE HA RECIBIDO RESPUESTA DEL PAQUETE
        if (simTime() >= txChannel->getTransmissionFinishTime()) {
            EV << "SALTA EL TIMEOUT DEL PAQUETE: " << mensajeEnviado->getName();
            mensajeEnviado->setTimestamp(simTime());
            send(mensajeEnviado->dup(), "sender$o");
            scheduleAt(txChannel->getTransmissionFinishTime(),
                    setTimeoutEvento);

        } else {
            scheduleAt(txChannel->getTransmissionFinishTime(), timeoutEvento);
        }

    } else if (msg == setTimeoutEvento) {
       scheduleAt(
                simTime()
                        + (txChannel->getDelay()) * 2 + (lenACK/txChannel->getDatarate())+1,
                timeoutEvento);
    } else {
        paquete = check_and_cast<Paquete *>(msg);

        if (msg->arrivedOn("paquetes")) { //PAQUETES DE LA FUENTE
            //EV << "Mensaje a enviar\n";

            sendCopyOf(paquete);

        } else if (msg->arrivedOn("sender$i")) {

            if (mensajeEnviado->getTimestamp() == paquete->getTimestamp()
                    && mensajeEnviado->getSecuencia()
                            == paquete->getSecuencia()) { //Si no se cumple esto descartar porque es paquete viejo
                cancelEvent(timeoutEvento);

                if (setTimeoutEvento->isScheduled())
                    cancelEvent(setTimeoutEvento);

                if (paquete->hasBitError() || paquete->getAck() == 0) { //ACK/NACK CON ERROR o NACK, REENVIO
                    EV << "ACK/NACK CON ERROR NECESITO REENVIAR: "
                              << mensajeEnviado->getName();
                    mensajeEnviado->setTimestamp(simTime());
                    send(mensajeEnviado->dup(), "sender$o");
                    scheduleAt(txChannel->getTransmissionFinishTime(),
                            setTimeoutEvento);

                } else { //ACK
                    EV << "ACK RECIBIDO: " << mensajeEnviado->getName();
                    delete (mensajeEnviado);
                    mensajeEnviado = NULL;

                    if (!txQueue->isEmpty()) {
                        scheduleAt(simTime(), enviarMensajeEvento);
                    }
                }
            } else {
                EV << "LLEGA ALGO DE UN PAQUETE VIEJO. DESCARTAR";
            }
        }

        delete (paquete);
    }
}

void StopWait::sendCopyOf(Paquete* paquete) {

    if (txQueue->isEmpty() && mensajeEnviado == NULL) {
        simtime_t timer = 0;

        if (simTime() >= txChannel->getTransmissionFinishTime())
            timer = simTime();
        else
            timer = txChannel->getTransmissionFinishTime();

        scheduleAt(timer, enviarMensajeEvento);
    }

    txQueue->insert(paquete->dup());
}
