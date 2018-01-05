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


using namespace omnetpp;

const short max_gates = 10;

class Router: public cSimpleModule {
private:

    const short max_net = 99;
    const short min_net = 0;

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

    int down_inc;
    int down_outc;
    int up_inc;
    int up_outc;
    bool down_in[max_gates];
    bool down_out[max_gates];
    bool up_in[max_gates];
    bool up_out[max_gates];
    route* routes;
    int n_routes;

    unsigned int direccion;
    unsigned int destino;
    int header_tam;
    int ttl;

    cXMLElement* xml;
protected:
    void initialize();
    void handleMessage(cMessage* msg);
    int config(cXMLElement *xml);
    void rutar(Red* red);
    void send_up(Red* red);
public:
    Router();
    virtual ~Router();
};

Define_Module(Router);

#endif /* ROUTER_H_ */
