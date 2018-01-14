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

#ifndef Canal_H
#define Canal_H

#include <omnetpp.h>
#include <omnetpp/cdataratechannel.h>

using namespace omnetpp;

class Canal: public cDatarateChannel {
protected:
    double packetLoss;
    double packetTotal;
    double packetLost;
    void refreshDisplay() const override;
public:

    explicit Canal(const char *name = nullptr);
    virtual ~Canal();
    virtual void initialize() override;
    virtual void processMessage(cMessage *msg, simtime_t t, result_t& result)
            override;
};

#endif // ifndef __INET_Canal_H

