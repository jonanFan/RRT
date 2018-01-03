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

        @display("bgb=833.1125,349.63748");

    types:
        channel C extends ned.DatarateChannel
        {
            datarate = 1bps;
            per = 0.2;
            delay = 100s;
        }

    submodules:
        Fuente1: Fuente {
            @display("p=45,33");
            lambda = 1000;
            startTime = 20;
            tamPaquete = 1024;
        }
        Fuente2: Fuente {
            @display("p=44.6125,107.899994");
            lambda = 1000;
            startTime = 20;
            tamPaquete = 1024;
        }
        Fuente3: Fuente {
            @display("p=44.6125,182.59999");
            lambda = 1000;
            startTime = 20;
            tamPaquete = 1024;
        }
        Fuente4: Fuente {
            @display("p=44.6125,258.3375");
            lambda = 1000;
            startTime = 20;
            tamPaquete = 1024;
        }
        Fuente5: Fuente {
            @display("p=44.6125,258.3375");
            lambda = 1000;
            startTime = 20;
            tamPaquete = 1024;
        }
        Receptor: Receptor {
            @display("p=600.71246,148.3625");
            probACKLoss = 0.3;
            probPacketLoss = 0.3;
        }
        Mux: Mux {
            @display("p=285.3125,148.3625");
        }
    connections:
        Fuente1.out --> Mux.in++;
        Fuente2.out --> Mux.in++;

        Fuente3.out --> Mux.in++;

        Fuente4.out --> Mux.in++;
        Fuente5.out --> Mux.in++;

        Mux.out <--> C <--> Receptor.receiver;
}
