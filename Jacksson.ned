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
        **.lenACK = 0bit;
        **.transporteHeaderTam = 0bit;
        **.redHeaderTam = 0bit;
        **.TTL = 10;

        **.lambda = 0.5s;
        **.startTime = exponential(0.5s);
        **.tamPaquete = 1000bit;
        **.answerAck = false;

        **.datarate = 3000bps;
        **.per = 0;
        **.delay=0;


        @display("bgb=2009.535,1061.1975");

    types:
        channel C1 extends Canal
        {
            packetLoss = 0;
        }

        channel C2 extends Canal
        {
            packetLoss = 0;
        }

        channel C3 extends Canal
        {
            packetLoss = 0;
        }

        channel C4 extends Canal
        {
            packetLoss = 0;
        }

        channel C5 extends Canal
        {
            packetLoss = 0;
        }

        channel C6 extends Canal
        {
            packetLoss = 0;
        }

        channel C7 extends Canal
        {
            packetLoss = 0;
        }

    submodules:
        Fuente1: Fuente {
            @display("p=170.8575,333.8775");
            //lambda = exponential(1000);
            //startTime = 20s;
            //tamPaquete = exponential(1024);
        }

        Fuente2: Fuente {
            @display("p=760.2375,128.535");
        }

        Fuente5: Fuente {
            @display("p=194.37,797.8575");
        }

        Receptor3: Receptor {
            @display("p=1758.735,333.8775");
        }

        Receptor4: Receptor {
            @display("p=1708.5751,807.2625");
        }

        Transmisor1: TransmisorDummy {
            @display("p=289.9875,333.8775");
            puerto = 0;
            dstPuerto = 0;
        }

        Transmisor2: TransmisorDummy {
            @display("p=960.8775,128.535");
            puerto = 0;
            dstPuerto = 0;
        }

        Transmisor5: TransmisorDummy {
            @display("p=376.2,797.8575");
            puerto = 0;
            dstPuerto = 0;
        }

        ReceptorTransporte3: ReceptorTransporte {
            @display("p=1572.2025,333.8775");
            puerto = 0;
        }

        ReceptorTransporte4: ReceptorTransporte {
            @display("p=1478.1525,807.2625");
            puerto = 0;
        }

        Router1: Router {
            @display("p=427.9275,333.8775");
            direccion = 1;
            destino = 3;
            configuracion = xmldoc("router1.xml");

        }

        Router2: Router {
            @display("p=854.28754,333.8775");
            direccion = 2;
            destino = 3;
            configuracion = xmldoc("router2.xml");
        }

        Router3: Router {
            @display("p=1399.7775,333.8775");
            direccion = 3;
            configuracion = xmldoc("router3.xml");

        }

        Router4: Router {
            @display("p=1258.7025,807.2625");
            direccion = 3;
            configuracion = xmldoc("router4.xml");
        }

        Router5: Router {
            @display("p=559.59753,797.8575");
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

        Router1.down_layer[0] <--> C1 <--> Router2.down_layer[0];
        Router1.down_layer[1] <--> C2 <--> Router5.down_layer[0];

        Router2.down_layer[1] <--> C3 <--> Router5.down_layer[1];
        Router2.down_layer[3] <--> C4 <--> Router3.down_layer[0];
        Router2.down_layer[2] <--> C5 <--> Router4.down_layer[1];

        Router5.down_layer[2] <--> C6 <--> Router4.down_layer[0];
        Router4.down_layer[2] <--> C7 <--> Router3.down_layer[1];



        Router3.up_layer[0] <--> ReceptorTransporte3.down_layer;
        ReceptorTransporte3.up_layer --> Receptor3.down_layer;

        Router4.up_layer[0] <--> ReceptorTransporte4.down_layer;
        ReceptorTransporte4.up_layer --> Receptor4.down_layer;
}


