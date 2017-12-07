(* ::Package:: *)

(* ::Title:: *)
(*CASO 1I*)


(* ::Input:: *)
(*<< "D:\Users\jontx\Dropbox\Clase\2 Master\RRT\Caso 2\drawTx.m"*)
(*<<"D:\Users\jontx\Dropbox\Clase\2 Master\RRT\Caso 2\RandomData.m"*)


(* ::Input:: *)
(*?drawTx`**)


(* ::Input:: *)
(*?RandomData`**)


(* ::Subtitle:: *)
(*Parte 0: Primeros pasos y cola M/M/1*)


(* ::Text::RGBColor[1, 0, 0]:: *)
(*1. Estudiar la librer\[IAcute]a de representaci\[OAcute]n de paquetes que se proporciona para identificar como se definen los par\[AAcute]metros de la transmisi\[OAcute]n y que formato deben tener los paquetes que se proporcionan para la representaci\[OAcute]n.*)


(* ::Text:: *)
(*Antes de usar la librer\[IAcute]a tenemos que inicializarla con SetIniParDraw. Esta funcion recibe como parametros el tiempo de propagaci\[OAcute]n y el ts.*)
(**)
(*Despues usamos DrawWin para dibujar el marco de tiempo y DrawPacket para dibujar los paquetes. *)
(**)
(*DrawWin toma como parametros el tiempo de inicio, el tiempo total que se va a dibujar y el m\[OAcute]dulo que se utilizar\[AAcute] para numerar las secuencias. Por otro lado, DrawPacket toma como parametro una variable con el siguiente formato: { tiempo de inserci\[OAcute]n, tasa de servicio , n\[UAcute]mero secuencia, error transmisi\[OAcute]n, n\[UAcute]mero de repeticiones}.*)
(**)
(*OJO!!!. La tasa de servicio debe ser multiplo de 9600 ya que, por como esta hecha la librer\[IAcute]a, un segundo equivale a 9600.*)


(* ::Input:: *)
(*packet={1,9600*3,1,0,0}; *)
(*SetIniParDraw[5,1];*)
(*Show[DrawWin[0,20,8],DrawPacketTx[packet]]*)


(* ::Input:: *)
(*packetList=Table[{2+n*10,9600,n+1,0,0},{n,0,9}];*)
(*Manipulate[Show[DrawWin[origin,ww,8],Map[DrawPacketTx[#]&,packetList]],{origin,0,100-ww},{ww,10,50}]*)


(* ::Text:: *)
(*En el caso 1 hemos hecho unas funciones que trabajan con el tiempo de llegada y con el tiempo de salida. Sin embargo, para genererar los paquetes nos hace falta calcular el tiempo de inserci\[OAcute]n. Ello se consigue restandole al tiempo de salida el tiempo de servicio.*)


(* ::Text::RGBColor[1, 0, 0]:: *)
(*2. Probar la representaci\[OAcute]n de la librer\[IAcute]a para una cola M/M/1.*)


(* ::Input:: *)
(*FifoSchedulling[arrivalsTime_,serviceTime_]:=*)
(*Module[{n,checkTime},n=1;checkTime=arrivalsTime[[1]];*)
(*Map[(If[checkTime>=#,checkTime+=serviceTime[[n++]],checkTime=#+serviceTime[[n++]]])&,arrivalsTime]]*)
(**)
(**)
(*CalculateMM1Packets[insertionTime_, serviceTime_]:=*)
(*Module[{n},*)
(*n=0;*)
(*Map[ *)
(*({#, 9600*serviceTime[[n+1]],n++, 0, 0})&, insertionTime]*)
(*]*)
(**)
(*SimTxMM1[lamdaMM1_,muMM1_,nPacketsMM1_,tpropMM1_,tsMM1_]:=Module[*)
(**)
(*{arrivalsTimeMM1, serviceTimeMM1,departureTimeMM1,insertionTimeMM1,  packetsMM1},*)
(*( *)
(*arrivalsTimeMM1=Accumulate[Table[RandomExp[lamdaMM1],nPacketsMM1]];*)
(*serviceTimeMM1=Table[RandomExp[muMM1], nPacketsMM1];*)
(*SetIniParDraw[tpropMM1,tsMM1];*)
(*departureTimeMM1=FifoSchedulling[arrivalsTimeMM1, serviceTimeMM1];*)
(*insertionTimeMM1=departureTimeMM1-serviceTimeMM1;*)
(*packetsMM1=CalculateMM1Packets[insertionTimeMM1, serviceTimeMM1];*)
(*Return[packetsMM1]*)
(*)]*)
(**)


(* ::Input:: *)
(*muMM1=100;*)
(*lamdaMM1=80;*)
(*nPacketsMM1=1000;*)
(*tpropMM1=0.05;*)
(*tsMM1=0.005;*)
(**)
(*packetsMM1=SimTxMM1[lamdaMM1,muMM1,nPacketsMM1,tpropMM1,tsMM1];*)
(*SetIniParDraw[tpropMM1,tsMM1];*)
(*Manipulate[Show[DrawWin[origin,ww,8],Map[DrawPacketTx[#]&,packetsMM1]],{origin,packetsMM1[[1]][[1]]-0.0001,packetsMM1[[-1]][[1]]+2*tpropMM1+tsMM1-ww},{ww,0.1,1}]*)
(**)
(**)


(* ::Text:: *)
(*Tal y como se puede observar, la simulacion cumple con el funcionamiento de una cola M/M/1. Los paquetes que llegan salen nada mas haya hueco en la cola.*)


(* ::Subtitle:: *)
(*Parte I: Stop & Wait*)


(* ::Text:: *)
(*Stop & Wait consiste en que un paquete no se envie hasta recibir la confirmaci\[OAcute]n de que el paquete anterior ha llegado correctamente. Es decir, el tiempo de espera de un paquete a otro viene dado por el tiempo de servicio mas 2 veces el tiempo de propagaci\[OAcute]n mas el tiempo que se tarda en procesar y generar el ACK en el receptor.*)
(**)
(*Por otro lado, si un paquete no recibe confirmaci\[OAcute]n, este se reenviar\[AAcute] hasta que llegue correctamente, y los dem\[AAcute]s paquetes deber\[AAcute]n esperar.*)


(* ::Input:: *)
(*StopAndWait[arrivalsTime_, serviceTime_,tprop_, ts_, prob_, nPacketsTotal_]:=*)
(*Module[{i,nSec, insertionTime, packetList},*)
(*i=1;*)
(*nSec=0;*)
(*insertionTime=0;*)
(*packetList={};*)
(*Map[*)
(*( *)
(*If[# > insertionTime, insertionTime=#; ];*)
(*While[RandomReal[] < prob && Length[packetList]< nPacketsTotal,*)
(*AppendTo[packetList, {insertionTime,9600* serviceTime[[i]],nSec,1,0}];*)
(**)
(*insertionTime+=(serviceTime[[i]]+2*tprop+ts);];*)
(**)
(*If[Length[packetList]< nPacketsTotal,*)
(*AppendTo[packetList, {insertionTime,9600* serviceTime[[i]],nSec++,0,0}];*)
(**)
(*insertionTime+=(serviceTime[[i++]]+2*tprop+ts); *)
(*];*)
(**)
(*)&,arrivalsTime];*)
(*Return[packetList]*)
(*]*)


(* ::Input:: *)
(*SimTxSW[lamdaSW_,muSW_,nPacketsSW_,tpropSW_,tsSW_,p_]:=Module[*)
(**)
(*{arrivalsTimeSW, serviceTimeSW, packetsSW},*)
(*( *)
(*arrivalsTimeSW=Accumulate[Table[RandomExp[lamdaSW],nPacketsSW]];*)
(*serviceTimeSW=Table[RandomExp[muSW], nPacketsSW];*)
(*SetIniParDraw[tpropSW,tsSW];*)
(*packetsSW=StopAndWait[arrivalsTimeSW, serviceTimeSW,tpropSW, tsSW, p, nPacketsSW];*)
(*Return[packetsSW]*)
(*)]*)


(* ::Input:: *)
(*muSW=2.5;*)
(*lamdaSW=1.5;*)
(*nPacketsSW=1000;*)
(*tpropSW=0.01;*)
(*tsSW=0;*)
(*errorProbSW=0.02;*)
(*packetsSW=SimTxSW[lamdaSW,muSW,nPacketsSW, tpropSW, tsSW, errorProbSW];*)
(*Manipulate[Show[DrawWin[origin,ww,8],Map[DrawPacketTx[#]&,packetsSW]],{origin,0,packetsSW[[-1]][[1]]+2*tpropSW+tsSW-ww},{ww,0.1,1}]*)


(* ::Subtitle:: *)
(*Parte segunda*)


(* ::Text:: *)
(*1. Dibujar la evoluci\[OAcute]n del throughput a lo largo de la transmisi\[OAcute]n*)


(* ::Text:: *)
(*El throughput de la transmisi\[OAcute]n en cada instante se calcula como el n\[UAcute]mero de secuencia del paquete entre el tiempo de inserci\[OAcute]n del mismo. Se utiliza el n\[UAcute]mero de secuencia como referencia de la evoluci\[OAcute]n de la transmisi\[OAcute]n ya que este se incrementa cada vez que se env\[IAcute]a un paquete correcto y se incrementa hasta el infinito.*)


(* ::Input:: *)
(*ThroughputTx[packetList_]:=Map[(#[[3]]/#[[1]])&,packetList];*)


(* ::Input:: *)
(*throughputSW=ThroughputTx[packetsSW];*)
(*ListLinePlot[throughputSW]*)


(* ::Text:: *)
(*2. Dibujar la gr\[AAcute]fica te\[OAcute]rica de throughput m\[AAcute]ximo en funci\[OAcute]n del factor a, p, tI y \[Rho]. Hacer gr\[AAcute]ficas variando cada uno de ellos.*)


(* ::Input:: *)
(*ThroughputTeoricoSW[a_,p_,ti_]:=(1-p)/(a*ti)*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de a*)


(* ::Input:: *)
(*Manipulate[Plot[ThroughputTeoricoSW[a,p,ti], {a,1,20}],{p, 0,1}, {ti,0.01,1 }]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de p*)


(* ::Input:: *)
(*Manipulate[Plot[ThroughputTeoricoSW[a,p,ti], {p,0,1}],{a, 1,20}, {ti,0.01,1}]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de ti*)


(* ::Input:: *)
(*Manipulate[Plot[ThroughputTeoricoSW[a,p,ti], {ti,0.0001,1}],{p, 0,1}, {a,1,20 }]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de \[Rho]*)
(**)
(*En este caso se ha de tener en cuenta que ti=1/mu y que \[Rho]=lamda/mu, por lo que ti=ro/lamda*)


(* ::Input:: *)
(*Manipulate[Plot[ThroughputTeoricoSW[a,p,ro/\[Lambda]], {ro,0,1}],{p, 0,1}, {a,1,20 }, {\[Lambda],1,50}]*)


(* ::Text:: *)
(*3.  Calcular el punto de trabajo en esas gr\[AAcute]ficas para una combinaci\[OAcute]n cualesquiera de esos par\[AAcute]metros y ver cu\[AAcute]nto se aproximan a los valores te\[OAcute]ricos, supuestas muestras de 1000, 2000 o 5000 segundos.*)


(* ::Text:: *)
(*En este apartado se va a comparar cuanto se aproxima la simulaci\[OAcute]n al resultado te\[OAcute]rico. Asimismo, se va a observar el efecto que tiene variar cada uno de los par\[AAcute]metros en la simulaci\[OAcute]n.*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de a*)


(* ::Input:: *)
(*Manipulate[Show[Plot[ThroughputTeoricoSW[ax,Prob,ti], {ax,1,20},AxesLabel->{A, \[Gamma]}, PlotRange->All],Graphics[{PointSize[Large],Green,Point[{{a,Last[ThroughputTx[SimTxSW[\[Rho]/ti,1/ti,Paquetes,ti*(a-1)/2, 0,Prob]]]}}]   ,PlotRange->Full  }     ]] ,{a,1,20},{Prob, 0,1},  {  \[Rho], 1, 0.00000001}, {ti, 0.1, 0.0001},{Paquetes, {100,1000,2000,5000}}]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de p*)


(* ::Input:: *)
(*Manipulate[Show[Plot[ThroughputTeoricoSW[a,Probx,ti], {Probx,0,1},AxesLabel->{prob, \[Gamma]}, PlotRange->All],Graphics[{PointSize[Large],Green,Point[{{Prob,Last[ThroughputTx[SimTxSW[\[Rho]/ti,1/ti,Paquetes,ti*(a-1)/2, 0,Prob]]]}}]  }     ]] ,{a,1,20},{Prob, 0.0009,1},  {  \[Rho], 1, 0.00000001}, {ti, 0.1, 0.0001},{Paquetes, {100,1000,2000,5000}}]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de ti*)


(* ::Input:: *)
(*Manipulate[Show[Plot[ThroughputTeoricoSW[a,Prob,tix], {tix,0.0001,1},AxesLabel->{Ti, \[Gamma]}],Graphics[{PointSize[Large],Green,Point[{{ti,Last[ThroughputTx[SimTxSW[\[Rho]/ti,1/ti,Paquetes,ti*(a-1)/2, 0,Prob]]]}}]  }     ]] ,{a,1,20},{Prob, 0,1},  {  \[Rho], 1, 0.00000001}, {ti, 0.084, 1},{Paquetes, {100,1000,2000,5000}}]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de \[Rho]*)


(* ::Input:: *)
(*Manipulate[Show[Plot[ThroughputTeoricoSW[a,Prob,rox/\[Lambda]], {rox,0.0001,1},AxesLabel->{ro, \[Gamma]}],Graphics[{PointSize[Large],Green,Point[{{ \[Rho],Last[ThroughputTx[SimTxSW[\[Lambda],\[Lambda]/\[Rho],Paquetes,(\[Rho]/\[Lambda])*(a-1)/2, 0,Prob]]]}}]  }     ]] ,{a,10,20},{Prob, 0,1},  {  \[Rho], 0.1,1},{\[Lambda], 1,10},{Paquetes, {100,1000,2000,5000}}]*)


(* ::Text:: *)
(*Tal y como se puede observar, independientemente del par\[AAcute]metro que se est\[EAcute] variando, la simulaci\[OAcute]n se aproxima bastante al valor te\[OAcute]rico por lo que se deduce que la implementaci\[OAcute]n del Stop & Wait se ha realizado de manera correcta.*)


(* ::Text:: *)
(*4. Dibujar los resultados supuesta la aplicaci\[OAcute]n de las abstracciones de rendimiento en una cola M/M/1 supuestas tasas corregidas*)


(* ::Text:: *)
(*El protocolo Stop & Wait se puede simular mediante una cola M/M/1. Para ello, basta con establecer como mu el throughput m\[AAcute]ximo te\[OAcute]rico del protocolo Stop & Wait. A continuaci\[OAcute]n, se contrasta el throughput te\[OAcute]rico con el throughput obtenido de simular el protocolo y con el throughput obtenido de utilizar una cola M/M/1 con tasas corregidas.*)
(**)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de a*)


(* ::Input:: *)
(*Manipulate[Show[Plot[ThroughputTeoricoSW[ax,Prob,ti], {ax,1,20},AxesLabel->{A, \[Gamma]}, PlotRange->All],Graphics[{PointSize[Large],Green,Point[{{a,Last[ThroughputTx[SimTxSW[\[Rho]/ti,1/ti,Paquetes,ti*(a-1)/2, 0,Prob]]]}}] ,Blue,Point[{{a,Last[ThroughputTx[SimTxMM1[\[Rho]/ti,(1-Prob)/(a*ti),Paquetes,ti*(a-1)/2, 0]]]}}]  ,PlotRange->Full  }     ]] ,{a,1,20},{Prob, 0,1},  {  \[Rho], 1, 0.00000001}, {ti, 0.1, 0.0001},{Paquetes, {100,1000,2000,5000}}]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de p*)


(* ::Input:: *)
(*Manipulate[Show[Plot[ThroughputTeoricoSW[a,Probx,ti], {Probx,0,1},AxesLabel->{prob, \[Gamma]}, PlotRange->All],Graphics[{PointSize[Large],Green,Point[{{Prob,Last[ThroughputTx[SimTxSW[\[Rho]/ti,1/ti,Paquetes,ti*(a-1)/2, 0,Prob]]]}}]  ,Blue,Point[{{Prob,Last[ThroughputTx[SimTxMM1[\[Rho]/ti,(1-Prob)/(a*ti),Paquetes,ti*(a-1)/2, 0]]]}}]}     ]] ,{a,1,20},{Prob, 0.0009,1},  {  \[Rho], 1, 0.00000001}, {ti, 0.1, 0.0001},{Paquetes, {100,1000,2000,5000}}]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de ti*)


(* ::Input:: *)
(*Manipulate[Show[Plot[ThroughputTeoricoSW[a,Prob,tix], {tix,0.0001,1},AxesLabel->{Ti, \[Gamma]}],Graphics[{PointSize[Large],Green,Point[{{ti,Last[ThroughputTx[SimTxSW[\[Rho]/ti,1/ti,Paquetes,ti*(a-1)/2, 0,Prob]]]}}]  ,Blue,Point[{{ti,Last[ThroughputTx[SimTxMM1[\[Rho]/ti,(1-Prob)/(a*ti),Paquetes,ti*(a-1)/2, 0]]]}}]}     ]] ,{a,1,20},{Prob, 0,1},  {  \[Rho], 1, 0.00000001}, {ti, 0.084, 1},{Paquetes, {100,1000,2000,5000}}]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de \[Rho]*)


(* ::Input:: *)
(*Manipulate[Show[Plot[ThroughputTeoricoSW[a,Prob,rox/\[Lambda]], {rox,0.0001,1},AxesLabel->{ro, \[Gamma]}],Graphics[{PointSize[Large],Green,Point[{{ \[Rho],Last[ThroughputTx[SimTxSW[\[Lambda],\[Lambda]/\[Rho],Paquetes,(\[Rho]/\[Lambda])*(a-1)/2, 0,Prob]]]}}]  ,Blue,Point[{{\[Rho],Last[ThroughputTx[SimTxMM1[\[Lambda],(1-Prob)/(a*(\[Rho]/\[Lambda])),Paquetes,(\[Rho]/\[Lambda])*(a-1)/2, 0]]]}}]}     ]] ,{a,10,30},{Prob, 0,1},  {  \[Rho], 0.1,1},{\[Lambda], 1,10},{Paquetes, {100,1000,2000,5000}}]*)


(* ::Text:: *)
(*El resultado en cualquiera de los dos casos simulados se aproxima bastante al valor te\[OAcute]rico.*)


(* ::Subtitle:: *)
(*Parte tercera*)


(* ::Text:: *)
(*1. Resolver la simulaci\[OAcute]n para GO-BACK-N. Inicialmente se puede hacer la simplificaci\[OAcute]n de no considerar las transmisiones dentro de la ventana con de error en la trama. El modulo tiene que ser 8 y ventana infinita. Posteriormente completar la simulaci\[OAcute]n considerando la transmisi\[OAcute]n de las tramas dentro de la ventana con error y sucesivas.*)


(* ::Text:: *)
(*A diferencia de Stop & Wait, en GO - BACK - N se posee una ventana que permite enviar cierta cantidad de paquetes tan pronto como se pueda, hasta llenar la ventana. Cada vez que se reciba la confirmaci\[OAcute]n del primer paquete de la ventana esta se desplazar\[AAcute], dejando un hueco libre y permitiendo que se env\[IAcute]e un nuevo paquete. Si por el contrario no se recibe la confirmaci\[OAcute]n del primer paquete, se reenviar\[AAcute] dicho paquete y todos los paquetes que hab\[IAcute]a en la ventana.*)
(**)
(*En este caso, la ventana es de 8 paquetes. Los primeros 8 paquetes se enviar\[AAcute]n como si estuvi\[EAcute]ramos en una cola M/M/1, el resto, seguir\[AAcute]n la l\[OAcute]gica hasta ahora explicada. Si la ventana tiene alg\[UAcute]n slot libre se enviar\[AAcute] el nuevo paquete, sino este tendr\[AAcute] que esperar.*)


(* ::Input:: *)
(*(*GBN[arrivalsTime_, serviceTime_,tprop_, ts_, prob_, N_]:=*)
(*Module[{i,firstInWin,nSec, insertionTime,packet, packetList, windowPackets},*)
(*i=1;*)
(*nSec=0;*)
(*insertionTime=0;*)
(*firstInWin=1;*)
(*packetList={};*)
(*windowPackets={};*)
(*Map[*)
(*( *)
(*If[# > insertionTime, insertionTime=#; ]; *)
(*While[Length[windowPackets] > 0 &&insertionTime\[GreaterEqual] (windowPackets[[1]][[1]]+windowPackets[[1]][[2]]/9600+2*tprop+ts)  ,*)
(**)
(*windowPackets=Drop[windowPackets,1];];*)
(*If[Length[windowPackets] \[GreaterEqual] N,*)
(*If[insertionTime <(windowPackets[[1]][[1]]+windowPackets[[1]][[2]]/9600+2*tprop+ts),*)
(* insertionTime=windowPackets[[1]][[1]]+windowPackets[[1]][[2]]/9600+2*tprop+ts; ];*)
(*];*)
(**)
(*packet={insertionTime,9600* serviceTime[[i]],nSec++,0,0};*)
(*AppendTo[windowPackets, packet];*)
(*AppendTo[packetList, packet];*)
(*insertionTime+=serviceTime[[i++]];*)
(**)
(*)&,arrivalsTime];*)
(*Return[packetList]*)
(*]*)*)
(**)
(*GBN[arrivalsTime_, serviceTime_,tprop_, ts_, prob_, N_, nPacketsTotal_]:=*)
(*Module[{i,j,firstInWin,nSec, insertionTime,packet, packetList, windowPackets},*)
(*i=1;*)
(*j=1;*)
(*nSec=0;*)
(*insertionTime=0;*)
(*firstInWin=1;*)
(*packetList={};*)
(*windowPackets={};*)
(*Map[*)
(*( *)
(*If[Length[packetList]< nPacketsTotal,*)
(*If[# > insertionTime, insertionTime=#; ]; *)
(*While[Length[windowPackets] > 0 &&insertionTime>= (windowPackets[[1]][[1]]+windowPackets[[1]][[2]]/9600+2*tprop+ts)  ,*)
(**)
(*If[windowPackets[[1]][[4]]==1,*)
(*If[windowPackets[[1]][[1]]+windowPackets[[1]][[2]]/9600+2*tprop+ts >= windowPackets[[-1]][[1]]+windowPackets[[-1]][[2]]/9600,*)
(*windowPackets[[1]][[1]]=windowPackets[[1]][[1]]+windowPackets[[1]][[2]]/9600+2*tprop+ts;,*)
(*windowPackets[[1]][[1]]=windowPackets[[-1]][[1]]+windowPackets[[-1]][[2]]/9600;];*)
(**)
(**)
(*If[RandomReal[] < prob,windowPackets[[1]][[4]]=1;, windowPackets[[1]][[4]]=0;];*)
(*For[j=2,j<= Length[windowPackets],j++,*)
(*windowPackets[[j]][[1]]=windowPackets[[j-1]][[1]]+windowPackets[[j-1]][[2]]/9600;*)
(*If[RandomReal[] < prob,windowPackets[[j]][[4]]=1;, windowPackets[[j]][[4]]=0;];*)
(*];*)
(*packetList=Join[packetList, windowPackets];*)
(*,*)
(*windowPackets=Drop[windowPackets,1];];];*)
(**)
(*If[Length[windowPackets] > 0,*)
(*If[insertionTime < windowPackets[[-1]][[1]]+windowPackets[[-1]][[2]]/9600, insertionTime=windowPackets[[-1]][[1]]+windowPackets[[-1]][[2]]/9600;];];*)
(**)
(**)
(*If[Length[windowPackets] >= N,*)
(*If[insertionTime <(windowPackets[[1]][[1]]+windowPackets[[1]][[2]]/9600+2*tprop+ts),*)
(*While[windowPackets[[1]][[4]]==1,*)
(*If[windowPackets[[1]][[1]]+windowPackets[[1]][[2]]/9600+2*tprop+ts >= windowPackets[[-1]][[1]]+windowPackets[[-1]][[2]]/9600,*)
(*windowPackets[[1]][[1]]=windowPackets[[1]][[1]]+windowPackets[[1]][[2]]/9600+2*tprop+ts;,*)
(*windowPackets[[1]][[1]]=windowPackets[[-1]][[1]]+windowPackets[[-1]][[2]]/9600;];*)
(**)
(**)
(*If[RandomReal[] < prob,windowPackets[[1]][[4]]=1;, windowPackets[[1]][[4]]=0;];*)
(*For[j=2,j<= Length[windowPackets],j++,*)
(*windowPackets[[j]][[1]]=windowPackets[[j-1]][[1]]+windowPackets[[j-1]][[2]]/9600;*)
(*If[RandomReal[] < prob,windowPackets[[j]][[4]]=1;, windowPackets[[j]][[4]]=0;];*)
(*];*)
(*packetList=Join[packetList, windowPackets];];*)
(*If[windowPackets[[1]][[1]]+windowPackets[[1]][[2]]/9600+2*tprop+ts >= windowPackets[[-1]][[1]]+windowPackets[[-1]][[2]]/9600,*)
(* insertionTime=windowPackets[[1]][[1]]+windowPackets[[1]][[2]]/9600+2*tprop+ts; ,*)
(*insertionTime=windowPackets[[-1]][[1]]+windowPackets[[-1]][[2]]/9600;*)
(*];];*)
(*];*)
(**)
(*If[RandomReal[] < prob,*)
(*packet={insertionTime,9600* serviceTime[[i]],nSec++,1,0};,*)
(*packet={insertionTime,9600* serviceTime[[i]],nSec++,0,0};];*)
(**)
(*AppendTo[windowPackets, packet];*)
(*AppendTo[packetList, packet];*)
(*insertionTime+=serviceTime[[i++]];];*)
(**)
(*)&,arrivalsTime];*)
(*Return[packetList]*)
(*]*)
(**)
(*SimTxGBN[lamdaGBN_,muGBN_,nPacketsGBN_,tpropGBN_,tsGBN_,moduloN_,p_]:=Module[*)
(**)
(*{arrivalsTimeGBN, serviceTimeGBN,packetsGBN},*)
(*( *)
(*arrivalsTimeGBN=Accumulate[Table[RandomExp[lamdaGBN],nPacketsGBN]];*)
(*serviceTimeGBN=Table[RandomExp[muGBN], nPacketsGBN];*)
(*SetIniParDraw[tpropGBN,tsGBN];*)
(*packetsGBN=GBN[arrivalsTimeGBN, serviceTimeGBN,tpropGBN, tsGBN, p,moduloN, nPacketsGBN];*)
(*Return[packetsGBN]*)
(*)];*)


(* ::Input:: *)
(*muGBN=100;*)
(*lamdaGBN=200;*)
(*nPacketsGBN=1000;*)
(*tpropGBN=0.1;*)
(*tsGBN=0.001;*)
(*errorProbGBN=0.1;*)
(*moduloN=8;*)
(**)
(*packetsGBN=SimTxGBN[lamdaGBN,muGBN,nPacketsGBN,tpropGBN,tsGBN,moduloN,errorProbGBN];*)
(**)
(*Manipulate[Show[DrawWin[origin,ww,8],Map[DrawPacketTx[#]&,packetsGBN]],{origin,0,packetsGBN[[-1]][[1]]+2*tpropGBN+tsGBN-ww},{ww,0.1,1}]*)


(* ::Subtitle:: *)
(*Parte cuarta*)


(* ::Text:: *)
(*En este apartado, al igual que en el protocolo Stop & Wait se pretende comparar el throughput te\[OAcute]rico con el throughput obtenido de la simulaci\[OAcute]n implementada y de la simulaci\[OAcute]n del protocolo mediante la cola M/M/1. Tal y como se observar\[AAcute] en las gr\[AAcute]ficas posteriores, el resultado de la simulaci\[OAcute]n se asemeja bastante al esperado por lo que la implementaci\[OAcute]n se puede dar como correcta.*)


(* ::Text:: *)
(*1. Dibujar las gr\[AAcute]ficas te\[OAcute]ricas de evoluci\[OAcute]n del throughput m\[AAcute]ximo en funci\[OAcute]n de\[NonBreakingSpace]\[NonBreakingSpace]a, p, tI y\[NonBreakingSpace]\[Rho].\[NonBreakingSpace]*)


(* ::Input:: *)
(*throughputGBN=ThroughputTx[packetsGBN];*)
(*ListLinePlot[throughputGBN]*)


(* ::Input:: *)
(*ThroughputTeoricoGBN[a_,p_,ti_]:=(1-p)/((1+(a-1)*p)*ti)*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de a*)


(* ::Input:: *)
(*Manipulate[Plot[ThroughputTeoricoGBN[a,p,ti], {a,1,20}],{p, 0.1,1}, {ti,0.01,1 }]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de p*)


(* ::Input:: *)
(*Manipulate[Plot[ThroughputTeoricoGBN[a,p,ti], {p,0,1}],{a, 3,20}, {ti,0.01,1}]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de ti*)


(* ::Input:: *)
(*Manipulate[Plot[ThroughputTeoricoGBN[a,p,ti], {ti,0.0001,1}],{p, 0.1,1}, {a,1,20 }]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de \[Rho]*)


(* ::Input:: *)
(*Manipulate[Plot[ThroughputTeoricoGBN[a,p,ro/\[Lambda]], {ro,0,1}],{p, 0.1,1}, {a,1,20 }, {\[Lambda],1,50}]*)


(* ::Text:: *)
(*2. Dibujar los resultados experimentales supuesta la simulaci\[OAcute]n de los protocolos*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de a*)


(* ::Input:: *)
(*Manipulate[Show[Plot[ThroughputTeoricoGBN[ax,Prob,ti], {ax,1,20},AxesLabel->{A, \[Gamma]}, PlotRange->All],Graphics[{PointSize[Large],Green,Point[{{a,Last[ThroughputTx[SimTxGBN[\[Rho]/ti,1/ti,Paquetes,ti*(a-1)/2, 0,8,Prob]]]}}]   ,PlotRange->Full  }     ]] ,{a,1,20},{Prob, 0.1,1},  {  \[Rho], 1, 0.00000001}, {ti, 0.1, 0.0001},{Paquetes, {100,1000,2000,5000}}]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de p*)


(* ::Input:: *)
(*Manipulate[Show[Plot[ThroughputTeoricoGBN[a,Probx,ti], {Probx,0,1},AxesLabel->{prob, \[Gamma]}, PlotRange->All],Graphics[{PointSize[Large],Green,Point[{{Prob,Last[ThroughputTx[SimTxGBN[\[Rho]/ti,1/ti,Paquetes,ti*(a-1)/2, 0,8,Prob]]]}}]  }     ]] ,{a,1,20},{Prob, 0.0009,1},  {  \[Rho], 1, 0.00000001}, {ti, 0.1, 0.0001},{Paquetes, {100,1000,2000,5000}}]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de ti*)


(* ::Input:: *)
(*Manipulate[Show[Plot[ThroughputTeoricoGBN[a,Prob,tix], {tix,0.0001,1},AxesLabel->{Ti, \[Gamma]}],Graphics[{PointSize[Large],Green,Point[{{ti,Last[ThroughputTx[SimTxGBN[\[Rho]/ti,1/ti,Paquetes,ti*(a-1)/2, 0,8,Prob]]]}}]  }     ]] ,{a,1,20},{Prob, 0,1},  {  \[Rho], 1, 0.00000001}, {ti, 0.084, 1},{Paquetes, {100,1000,2000,5000}}]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de \[Rho]*)


(* ::Input:: *)
(*Manipulate[Show[Plot[ThroughputTeoricoGBN[a,Prob,rox/\[Lambda]], {rox,0.0001,1},AxesLabel->{ro, \[Gamma]}],Graphics[{PointSize[Large],Green,Point[{{ \[Rho],Last[ThroughputTx[SimTxGBN[\[Lambda],\[Lambda]/\[Rho],Paquetes,(\[Rho]/\[Lambda])*(a-1)/2, 0,8,Prob]]]}}]  }     ]] ,{a,70,200},{Prob, 0.2,0.9999},  {  \[Rho], 0.1,1},{\[Lambda], 0.1,10},{Paquetes, {100,1000,2000,5000}}]*)


(* ::Text:: *)
(*3. Dibujar los resultados supuesta la aplicaci\[OAcute]n de las abstracciones de rendimiento en una cola M/M/1 supuestas tasas corregidas*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de a*)


(* ::Input:: *)
(*Manipulate[Show[Plot[ThroughputTeoricoGBN[ax,Prob,ti], {ax,1,20},AxesLabel->{A, \[Gamma]}, PlotRange->All],Graphics[{PointSize[Large],Green,Point[{{a,Last[ThroughputTx[SimTxGBN[\[Rho]/ti,1/ti,Paquetes,ti*(a-1)/2, 0,8,Prob]]]}}]  ,Blue,Point[{{a,Last[ThroughputTx[SimTxMM1[\[Rho]/ti,(1-Prob)/((1+(a-1)*Prob)*ti),Paquetes,ti*(a-1)/2, 0]]]}}] ,PlotRange->Full  }     ]] ,{a,1,20},{Prob, 0.1,0.9999},  {  \[Rho], 1, 0.00000001}, {ti, 0.1, 0.0001},{Paquetes, {100,1000,2000,5000}}]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de p*)


(* ::Input:: *)
(*Manipulate[Show[Plot[ThroughputTeoricoGBN[a,Probx,ti], {Probx,0,1},AxesLabel->{prob, \[Gamma]}, PlotRange->All],Graphics[{PointSize[Large],Green,Point[{{Prob,Last[ThroughputTx[SimTxGBN[\[Rho]/ti,1/ti,Paquetes,ti*(a-1)/2, 0,8,Prob]]]}}] ,Blue,Point[{{Prob,Last[ThroughputTx[SimTxMM1[\[Rho]/ti,(1-Prob)/((1+(a-1)*Prob)*ti),Paquetes,ti*(a-1)/2, 0]]]}}] }     ]] ,{a,1,20},{Prob, 0.0009,0.999999},  {  \[Rho], 1, 0.00000001}, {ti, 0.1, 0.0001},{Paquetes, {100,1000,2000,5000}}]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de ti*)


(* ::Input:: *)
(*Manipulate[Show[Plot[ThroughputTeoricoGBN[a,Prob,tix], {tix,0.0001,1},AxesLabel->{Ti, \[Gamma]}],Graphics[{PointSize[Large],Green,Point[{{ti,Last[ThroughputTx[SimTxGBN[\[Rho]/ti,1/ti,Paquetes,ti*(a-1)/2, 0,8,Prob]]]}}]  ,Blue,Point[{{ti,Last[ThroughputTx[SimTxMM1[\[Rho]/ti,(1-Prob)/((1+(a-1)*Prob)*ti),Paquetes,ti*(a-1)/2, 0]]]}}]}     ]] ,{a,1,20},{Prob, 0,0.9999},  {  \[Rho], 1, 0.00000001}, {ti, 0.084, 1},{Paquetes, {100,1000,2000,5000}}]*)


(* ::Text:: *)
(*Variaci\[OAcute]n del throughput maximo te\[OAcute]rico en funci\[OAcute]n de \[Rho]*)


(* ::Input:: *)
(*Manipulate[Show[Plot[ThroughputTeoricoGBN[a,Prob,rox/\[Lambda]], {rox,0.0001,1},AxesLabel->{ro, \[Gamma]}],Graphics[{PointSize[Large],Green,Point[{{ \[Rho],Last[ThroughputTx[SimTxGBN[\[Lambda],\[Lambda]/\[Rho],Paquetes,(\[Rho]/\[Lambda])*(a-1)/2, 0,8,Prob]]]}}]  ,Blue,Point[{{\[Rho],Last[ThroughputTx[SimTxMM1[\[Lambda],(1-Prob)/((1+(a-1)*Prob)*(\[Rho]/\[Lambda])),Paquetes,(\[Rho]/\[Lambda])*(a-1)/2, 0]]]}}]}     ]] ,{a,70,200},{Prob, 0.2,0.9999},  {  \[Rho], 0.1,1},{\[Lambda], 0.1,10},{Paquetes, {100,1000,2000,5000}}]*)
