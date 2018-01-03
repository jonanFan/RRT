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

#include "GBN.h"

GBN::GBN() {
    // TODO Auto-generated constructor stub
    txQueue = NULL;
    ventanaGBN = NULL;
    enviarMensajeEvento = new cMessage();
    timeoutEvento = new cMessage();
    reenviarEvento = new cMessage();
    tamVentana = 0;
    lenACK = 0;
    nEnviado = 0;
    reenviando = 0;
}

GBN::~GBN() {
    // TODO Auto-generated destructor stub
    if (txQueue != NULL)
        txQueue->~cQueue();

    if (ventanaGBN != NULL)
        ventanaGBN->~cQueue();

    cancelAndDelete(enviarMensajeEvento);
    cancelAndDelete(timeoutEvento);
    cancelAndDelete(reenviarEvento);
}

void GBN::initialize() {
    txChannel = (cDatarateChannel*) gate("sender$o")->getTransmissionChannel();
    txQueue = new cQueue();
    ventanaGBN = new cQueue();
    tamVentana = par("tamVentana");
    lenACK = par("lenACK");

    //EV << "El tamano de la ventana es " << tamVentana << "\n";
}

/* AQUI EL TIMEOUT DEBERIA SER CON ESTO Y CUANDO SE BORRE EL PAQUETE COGER EL TIMEOUT DE OTRO
 simTime()
 + (txChannel->getDelay()) * 2 + (lenACK/txChannel->getDatarate()*/

void GBN::handleMessage(cMessage* msg) {

    Paquete* paquete = NULL;
    simtime_t timer = 0;

    if (msg == enviarMensajeEvento && nEnviado < tamVentana
            && !txQueue->isEmpty()) { //SCHEDULER QUE ENVIA LOS PAQUETES CUANDO TOCA

        paquete = (Paquete*) txQueue->pop();

        EV << "ENVIANDO MENSAJE " << paquete->getName() << "\n";

        paquete->setTimestamp(simTime());
        paquete->setAck(-1);
        send(paquete->dup(), "sender$o");
        paquete->setTxFinish(txChannel->getTransmissionFinishTime());

        if (ventanaGBN->getLength() == 0) {
            scheduleAt(
                    txChannel->getTransmissionFinishTime()
                            + (txChannel->getDelay()) * 2
                            + (lenACK / txChannel->getDatarate()) + 1,
                    timeoutEvento);

            /*EV << "El timeout deberia saltar en "
                      << txChannel->getTransmissionFinishTime()
                              + (txChannel->getDelay()) * 2
                              + (lenACK / txChannel->getDatarate()) + 1 << "\n";

            EV << "El txfinish time es "
                      << txChannel->getTransmissionFinishTime() << "\n";

            EV << "El delay*2 es " << (txChannel->getDelay()) << "\n";

            EV << "El lenACK es " << lenACK << "\n";

            EV << "El datarate es " << txChannel->getDatarate() << "\n";

            EV << "El lenACK/datarate es "
                      << (lenACK / txChannel->getDatarate()) << "\n";*/
        }

        ventanaGBN->insert(paquete);

        if (++nEnviado < tamVentana && !txQueue->isEmpty())
            scheduleAt(txChannel->getTransmissionFinishTime(),
                    enviarMensajeEvento);

    } else if (msg == timeoutEvento) {
        EV << "HA SALTADO EL TIMEOUT DEL MENSAJE " << ((Paquete*) ventanaGBN->get(0))->getName() << "\n";
        resendWindow();
    } else if (msg == reenviarEvento) {

        int i;
        for (i = 0; i < ventanaGBN->getLength(); i++) {
            if (((Paquete*) ventanaGBN->get(i))->getTimestamp() == 0) { //BUSCO PAQUETES SIN REENVIAR POR SU TIMESTAMP
                paquete = ((Paquete*) ventanaGBN->get(i));
                break;
            }
        }

        if (paquete != NULL) //PAQUETE PARA REENVIAR
        {
            paquete->setTimestamp(simTime());
            paquete->setAck(-1);
            send(paquete->dup(), "sender$o");
            paquete->setTxFinish(txChannel->getTransmissionFinishTime());

            if (i < ventanaGBN->getLength() - 1) { //SI NO ES EL ULTIMO PAQUETE REENVIAR EL SIGUIENTE
                if (i == 0) {
                    scheduleAt(

                            txChannel->getTransmissionFinishTime()
                                    + (txChannel->getDelay()) * 2
                                    + (lenACK / txChannel->getDatarate()) + 1,
                            timeoutEvento);
                   /* EV << "El timeout deberia saltar en "
                              << ((Paquete*) ventanaGBN->get(0))->getTxFinish()
                                      + (txChannel->getDelay()) * 2
                                      + (lenACK / txChannel->getDatarate()) + 1
                              << "\n";*/
                }

                scheduleAt(txChannel->getTransmissionFinishTime(),
                        reenviarEvento);
            } else
                reenviando = 0;

        } else
            reenviando = 0;

    } else {
        paquete = check_and_cast<Paquete *>(msg);

        if (msg->arrivedOn("paquetes")) { //PAQUETES DE LA FUENTE
            sendCopyOf(paquete);

        } else if (msg->arrivedOn("sender$i")) { //PAQUETE DEL RECEPTOR

            Paquete* almacenado = NULL;
            int i = 0;

            /*EV << "Timestamp del paquete es " << paquete->getTimestamp()
                      << "\n";*/
            for (i = 0; i < ventanaGBN->getLength(); i++) { //BUSCAR EL PAQUETE RECIBIDO
                if (((Paquete*) ventanaGBN->get(i))->getSecuencia()
                        == paquete->getSecuencia()
                        && ((Paquete*) ventanaGBN->get(i))->getTimestamp()
                                == paquete->getTimestamp()) {
                    almacenado = (Paquete*) ventanaGBN->get(i);
                    break;
                }
            }

            if (almacenado != NULL) { //Se ha encontrado el paquete
               // EV << "PAQUETE ENCONTRADO\n";

                if (paquete->hasBitError() || paquete->getAck() == 0)
                    almacenado->setAck(0);
                else
                    almacenado->setAck(1);

                if (i == 0) //SI ES EL PRIMER PAQUETE MIRAR SI SE HA RECIBIDO BIEN O NO.
                            //SI SE HA RECIBIDO BIEN BORRAR TODOS LOS QUE TIENEN ACK
                            //--SI EL ULTIMO ES NACK REENVIAR TODO LO QUE HAY Y AÑADIR EN LOS HUECOS LOS SIGUIENTES
                            //--SI EL ULTIMO NO TIENE RESPUESTA AÑADIR EN LOS HUECOS SIGUIENTES
                            //SI SE HA RECIBIDO MAL REENVIAR TODOS
                        {
                   // EV << "PRIMER PAQUETE DE LA VENTANA\n";

                    if (timeoutEvento->isScheduled()) {
                        //EV << "CANCELAMOS TIMEOUT";
                        cancelEvent(timeoutEvento);
                    }
                    while (!ventanaGBN->isEmpty()
                            && ((Paquete*) ventanaGBN->get(0))->getAck() == 1) {
                       // EV << "ELIMINANDO PAQUETE DE LA VENTANA\n";
                        delete (ventanaGBN->pop());
                        nEnviado--;
                    }

                    /*EV << "AHORA LA VENTANA TIENE " << nEnviado
                              << " ELEMENTOS \n";*/

                    if (!ventanaGBN->isEmpty()
                            && ((Paquete*) ventanaGBN->get(0))->getAck() == 0) {
                        EV << "REENVIAR TODO LO DE LA VENTANA" << "\n";
                        resendWindow();
                    } else {

                        if (!ventanaGBN->isEmpty()) {
                            scheduleAt(
                                    ((Paquete*) ventanaGBN->get(0))->getTxFinish()
                                            + (txChannel->getDelay()) * 2
                                            + (lenACK / txChannel->getDatarate())
                                            + 1, timeoutEvento);

                          /*  EV << "El timeout deberia saltar en "
                                      << ((Paquete*) ventanaGBN->get(0))->getTxFinish()
                                              + (txChannel->getDelay()) * 2
                                              + (lenACK
                                                      / txChannel->getDatarate())
                                              + 1 << "\n";*/
                        }

                        if (!txQueue->isEmpty() && nEnviado < tamVentana
                                && !enviarMensajeEvento->isScheduled()) {
                            if (simTime()
                                    >= txChannel->getTransmissionFinishTime())
                                timer = simTime();
                            else
                                timer = txChannel->getTransmissionFinishTime();
                            scheduleAt(timer, enviarMensajeEvento);
                        }
                    }
                }
            } else {
                EV << "PAQUETE DESCARTADO POR SER VIEJO: " << paquete->getName()
                          << "\n";
            }

        }

        delete (paquete);
    }
}

void GBN::sendCopyOf(Paquete* paquete) {

    if (!reenviando && !enviarMensajeEvento->isScheduled()
            && (ventanaGBN->isEmpty() || nEnviado < tamVentana)) {
        simtime_t timer = 0;

        if (simTime() >= txChannel->getTransmissionFinishTime())
            timer = simTime();
        else
            timer = txChannel->getTransmissionFinishTime();

        scheduleAt(timer, enviarMensajeEvento);
    }

    //EV << "Almacenando mensaje " << paquete->getName() << "\n";
    txQueue->insert(paquete->dup());
}

void GBN::resendWindow() {

//MARCAR QUE SE VA A REENVIAR PARA NO METER NADA NUEVO EN LA VENTANA AUNQUE HAYA HUECO
    reenviando = 1;
    if (enviarMensajeEvento->isScheduled()) {
        cancelEvent(enviarMensajeEvento);
    }

    if (timeoutEvento->isScheduled()) {
       // EV << "CANCELAMOS TIMEOUT";
        cancelEvent(timeoutEvento);
    }

    for (int i = 0; i < ventanaGBN->getLength(); i++) {
        ((Paquete*) ventanaGBN->get(i))->setTimestamp(0); //MODIFICO TODOS PARA NO COGER RESPUESTAS DE PAQUETES VIEJOS
    }

    simtime_t timer = 0;

    if (simTime() >= txChannel->getTransmissionFinishTime())
        timer = simTime();
    else
        timer = txChannel->getTransmissionFinishTime();

    scheduleAt(timer, reenviarEvento);

}

