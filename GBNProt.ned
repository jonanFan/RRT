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

network GBNProt
{
    parameters:
        **.lenACK = 1;

        @display("bgb=826,265");
    types:
        channel C extends ned.DatarateChannel
        {
            datarate = 1bps;
            per = 0.2;
            delay = 100s;
        }
    submodules:
        Fuente: Fuente {
            @display("p=45,33");
            lambda = 1000;
            startTime = 20;
            tamPaquete = 1024;
        }
        Receptor: Receptor {
            @display("p=511.4875,32.1625");
            probACKLoss = 0;
            probPacketLoss = 0.4;
        }
        GBNProt: GBN {
            tamVentana = 2;
            @display("p=272.8625,32.1625");
        }
    connections:
        Fuente.out --> GBNProt.paquetes;
        Receptor.out --> C --> GBNProt.in;
        GBNProt.out --> C --> Receptor.in;
}
