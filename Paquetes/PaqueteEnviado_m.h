//
// Generated file, do not edit! Created by nedtool 5.2 from Paquetes/PaqueteEnviado.msg.
//

#if defined(__clang__)
#  pragma clang diagnostic ignored "-Wreserved-id-macro"
#endif
#ifndef __PAQUETEENVIADO_M_H
#define __PAQUETEENVIADO_M_H

#include <omnetpp.h>

// nedtool version check
#define MSGC_VERSION 0x0502
#if (MSGC_VERSION!=OMNETPP_VERSION)
#    error Version mismatch! Probably this file was generated by an earlier version of nedtool: 'make clean' should help.
#endif



/**
 * Class generated from <tt>Paquetes/PaqueteEnviado.msg:19</tt> by nedtool.
 * <pre>
 * //
 * // TODO generated message class
 * //
 * message PaqueteEnviado
 * {
 *     short gateId;
 * }
 * </pre>
 */
class PaqueteEnviado : public ::omnetpp::cMessage
{
  protected:
    short gateId;

  private:
    void copy(const PaqueteEnviado& other);

  protected:
    // protected and unimplemented operator==(), to prevent accidental usage
    bool operator==(const PaqueteEnviado&);

  public:
    PaqueteEnviado(const char *name=nullptr, short kind=0);
    PaqueteEnviado(const PaqueteEnviado& other);
    virtual ~PaqueteEnviado();
    PaqueteEnviado& operator=(const PaqueteEnviado& other);
    virtual PaqueteEnviado *dup() const override {return new PaqueteEnviado(*this);}
    virtual void parsimPack(omnetpp::cCommBuffer *b) const override;
    virtual void parsimUnpack(omnetpp::cCommBuffer *b) override;

    // field getter/setter methods
    virtual short getGateId() const;
    virtual void setGateId(short gateId);
};

inline void doParsimPacking(omnetpp::cCommBuffer *b, const PaqueteEnviado& obj) {obj.parsimPack(b);}
inline void doParsimUnpacking(omnetpp::cCommBuffer *b, PaqueteEnviado& obj) {obj.parsimUnpack(b);}


#endif // ifndef __PAQUETEENVIADO_M_H

