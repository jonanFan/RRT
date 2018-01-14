simple Fuente
{
    parameters:
        double lambda @unit(s) = default(10s);
        double startTime @unit(s)= default(20s);
        double tamPaquete @unit(bit)= default(1024bit);

        @display("i=block/source");
    gates:
        output down_layer;
}

simple Receptor
{				
        @display("i=block/sink");
    gates:
        input down_layer;
}

simple ReceptorTransporte
{
    parameters:
        int lenACK @unit(bit)= default(1bit);
        bool answerAck= default(true);
		int puerto=default(0);
		
        @display("i=block/transport");
    gates:
        output up_layer;
        inout down_layer;
}

simple TransmisorDummy
{
    parameters:
		int transporteHeaderTam @unit(bit)= default(10bit);
		int puerto=default(0);
		int dstPuerto=default(0);
		
        @display("i=block/transport");
    gates:
        input up_layer;
        inout down_layer;
}

simple Router
{
    parameters:
        @display("i=block/routing");
        int direccion = default(0);
        int destino = default(0);
        int TTL = default(10);
        int redHeaderTam @unit(bit) = default(0bit);
        xml configuracion = default(xmldoc("Red/Router.xml"));
    gates:
        inout up_layer[10] @loose;
        inout down_layer[10] @loose;
}

channel Canal extends ned.DatarateChannel
{
    @class(Canal);
    double packetLoss = default(0);  
}
