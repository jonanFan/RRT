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
        **.lenACK = 1;
        **.transporteHeaderTam=10;
        **.redHeaderTam=10;

        @display("bgb=531.495,484.41376");

    types:
        channel C extends Canal
        {
            datarate = 1bps;
            per = 0.2;
            delay = 100s;
            packetLoss = 0.5;
        }

    submodules:
        Fuente: Fuente {
            @display("p=116.13375,134.96625");
            lambda = 1000;
            startTime = 20;
            tamPaquete = 1024;
        }
        Receptor: Receptor {
            @display("p=392.34375,134.96625");
        }

        TransmisorDummy: TransmisorDummy {
            @display("p=116.13375,218.66624");
            puerto = 0;
            dstPuerto = 0;
        }

        ReceptorTransporte: ReceptorTransporte {
            @display("p=392.34375,218.66624");
            puerto = 0;
        }

        TransmisorRouter: Router {
            @display("p=116.13375,303.4125");
            direccion = 1;
            destino = 2;
            TTL = 10;
            configuracion = xmldoc("jackson1.xml");

        }

        ReceptorRouter: Router {
            @display("p=392.34375,303.4125");
            direccion = 2;
            TTL = 10;
            configuracion = xmldoc("jackson1.xml");
        }

    connections:
        Fuente.down_layer --> TransmisorDummy.up_layer;
        TransmisorDummy.down_layer <--> TransmisorRouter.up_layer[0];
        TransmisorRouter.down_layer[0] <--> C <--> ReceptorRouter.down_layer[0];
        ReceptorRouter.up_layer[0] <--> ReceptorTransporte.down_layer;
        ReceptorTransporte.up_layer --> Receptor.down_layer;
}


