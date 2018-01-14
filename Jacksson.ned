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

network Jacksson
{
    parameters:
        **.lenACK = 1bit;
        **.transporteHeaderTam = 0bit;
        **.redHeaderTam = 0bit;
        **.TTL = 10;

        **.lambda = uniform(0.4s, 0.6s);
        **.startTime = 1s;
        **.tamPaquete = 10bit;
        **.answerAck=false;


        @display("bgb=1250.1125,543.04254");

    types:
        channel C extends Canal
        {
            datarate = 20bps;
            per = 0;
            delay = 1s;
            packetLoss = 0;
        }

    submodules:
        Fuente1: Fuente {
            @display("p=91,239");
            //lambda = exponential(1000);
            //startTime = 20s;
            //tamPaquete = exponential(1024);
        }

        Fuente2: Fuente {
            @display("p=347.165,122.622505");
        }

        Fuente5: Fuente {
            @display("p=90.77251,422.0125");
        }

        Receptor3: Receptor {
            @display("p=1112,239");
        }

        Receptor4: Receptor {
            @display("p=1111.5651,422.0125");
        }

        Transmisor1: TransmisorDummy {
            @display("p=211,239");
            puerto = 0;
            dstPuerto = 0;
        }

        Transmisor2: TransmisorDummy {
            @display("p=547.82,122.622505");
            puerto = 0;
            dstPuerto = 0;
        }

        Transmisor5: TransmisorDummy {
            @display("p=272.3175,422.0125");
            puerto = 0;
            dstPuerto = 0;
        }

        ReceptorTransporte3: ReceptorTransporte {
            @display("p=926,239");
            puerto = 0;
        }

        ReceptorTransporte4: ReceptorTransporte {
            @display("p=882.24506,422.0125");
            puerto = 0;
        }

        Router1: Router {
            @display("p=348,239");
            direccion = 1;
            destino = 3;
            configuracion = xmldoc("router1.xml");

        }

        Router2: Router {
            @display("p=549,239");
            direccion = 2;
            destino = 3;
            configuracion = xmldoc("router2.xml");
        }

        Router3: Router {
            @display("p=753,239");
            direccion = 3;
            configuracion = xmldoc("router3.xml");

        }

        Router4: Router {
            @display("p=663,423");
            direccion = 3;
            configuracion = xmldoc("router4.xml");
        }

        Router5: Router {
            @display("p=455,423");
            direccion = 5;
            destino = 3;
            configuracion = xmldoc("router5.xml");
        }


    connections:
        Fuente1.down_layer --> Transmisor1.up_layer;
        Transmisor1.down_layer <--> Router1.up_layer[0];

        Fuente2.down_layer --> Transmisor2.up_layer;
        Transmisor2.down_layer <--> Router2.up_layer[0];

        Fuente5.down_layer --> Transmisor5.up_layer;
        Transmisor5.down_layer <--> Router5.up_layer[0];

        Router1.down_layer[0] <--> C <--> Router2.down_layer[0];
        Router1.down_layer[1] <--> C <--> Router5.down_layer[0];

        Router2.down_layer[1] <--> C <--> Router5.down_layer[1];
        Router2.down_layer[2] <--> C <--> Router4.down_layer[1];
        Router2.down_layer[3] <--> C <--> Router3.down_layer[0];

        Router5.down_layer[2] <--> C <--> Router4.down_layer[0];
        Router4.down_layer[2] <--> C <--> Router3.down_layer[1];



        Router3.up_layer[0] <--> ReceptorTransporte3.down_layer;
        ReceptorTransporte3.up_layer --> Receptor3.down_layer;

        Router4.up_layer[0] <--> ReceptorTransporte4.down_layer;
        ReceptorTransporte4.up_layer --> Receptor4.down_layer;
}


