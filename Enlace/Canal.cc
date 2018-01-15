//
// Copyright (C) 2005 Andras Varga
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program; if not, see <http://www.gnu.org/licenses/>.
//

#include "Canal.h"

Register_Class(Canal);

Canal::Canal(const char *name) :
        cDatarateChannel(name) {
}

Canal::~Canal() {
}

//Canal& Canal::operator=(const Canal& ch)
//{
//    if (this==&ch) return *this;
//    cDatarateChannel::operator=(ch);
//    numPackets = ch.numPackets;
//    numBits = ch.numBits;
//    fmt = ch.fmt;
//    return *this;
//}

void Canal::initialize() {
    packetLost = 0;
    packetTotal = 0;
    cDatarateChannel::initialize();
    packetLoss = par("packetLoss");
}

void Canal::processMessage(cMessage *msg, simtime_t t, result_t& result) {
    if (uniform(0, 1) >= packetLoss) {
        cDatarateChannel::processMessage(msg, t, result);
    } else {
        packetLost++;
        EV << "Paquete " << msg->getName() << " perdido\n";
        result.discard = true;
    }

    packetTotal++;
}

void Canal::refreshDisplay() const {
    char buf[40];

    if (packetTotal == 0)
        sprintf(buf, "Loss: 0%%. Caudal: %.2lf", packetLost / packetTotal * 100, packetTotal/simTime());
    else
        sprintf(buf, "Loss: %.2lf %%. Caudal: %.2lf", packetLost / packetTotal * 100, packetTotal/simTime());

    getDisplayString().setTagArg("t", 0, buf);
}

