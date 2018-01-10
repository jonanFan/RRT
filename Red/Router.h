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

#ifndef ROUTER_H_
#define ROUTER_H_

#include <omnetpp.h>
#include <omnetpp/cxmlelement.h>
#include "Paquetes/Red_m.h"
#include "Paquetes/PaqueteEnviado_m.h"
#include "Paquetes/General.h"
#include "Enlace/Canal.h"

using namespace omnetpp;

class Router: public cSimpleModule {
private:

    const short max_net = 100;
    const short min_net = 1;

    struct output {
        short gate;
        double prob;
    };

    struct route {
        int start;
        int stop;
        int n_gates;
        output * gates;
    };

    struct gates {
        bool input;
        bool output;
        Canal *txChannel;
        cQueue* txQueue;
        PaqueteEnviado* enviado;
    };

  /*  bool down_in[max_gates];
    bool down_out[max_gates];
    bool up_in[max_gates];
    bool up_out[max_gates];*/
    gates up_gates[max_gates];
    gates down_gates[max_gates];
    route* routes;
    int n_routes;

    unsigned int direccion;
    unsigned int destino;
    int header_tam;
    int ttl;

protected:
    void initialize();
    void initializeGate(gates* gateInit);
    void handleMessage(cMessage* msg);
    int config(cXMLElement *xml);
    bool rutar(Red* red);
    void send_up(Red* red);
    void notify_sent(Red* red, simtime_t finishTime, simtime_t delay, double datarate);
public:
    Router();
    virtual ~Router();
};

Define_Module(Router);

#endif /* ROUTER_H_ */
