(* ::Package:: *)

(* ::Title:: *)
(*CASO 1*)


(* ::Subtitle:: *)
(*Parte primera*)


(* ::Text:: *)
(*1. Desarrollar un sistema generador de n\[UAcute]meros aleatorios basado en un generador lineal congruencial mixto que siga una distribuci\[OAcute]n uniforme entre[0, 1].*)


(* ::Input:: *)
(*<< "D:\Users\jontx\Dropbox\Clase\2 Master\RRT\Caso 1\RandomData.m"*)


(* ::Text:: *)
(*El siguiente comando permite ver cuales son las funciones que incluye el fichero RandomData.m *)


(* ::Input:: *)
(*?RandomData`**)


(* ::Text:: *)
(*La librer\[IAcute]a que nos proporciona Armando dispone de una funci\[OAcute]n RandomData que no es mas que un generador de n\[UAcute]meros aleatorios que sigue una distribuci\[OAcute]n uniforme entre 0 y 1.*)


(* ::Text:: *)
(*2. Probar el generador y demostrar mediante un histograma la bondad del generador.*)


(* ::Input:: *)
(*muestras=10000;*)


(* ::Input:: *)
(*listaUni=Table[RandomData[], {i, muestras}];*)


(* ::Input:: *)
(*Histogram[listaUni, 20, "PDF"]*)


(* ::Text:: *)
(*Disponer de una distribuci\[OAcute]n uniforme entre 0 y 1 quiere decir que todos los valores generados son igual de probables, y que la funci\[OAcute]n de densidad de probabilidad del generador debe ser constante en el intervalo [0,1] con valor 1/(1-0)=1 y 0 en el resto de intervalos. Como vemos, el resultado obtenido con el generador que nos proporciona la librer\[IAcute]a RandomData.m se aproxima bastante a esta definici\[OAcute]n te\[OAcute]rica.*)


(* ::Text:: *)
(*3. Implementar el m\[EAcute]todo de transformada inversa para obtener una distribuci\[OAcute]n aleatoria exponencial de tiempo entre llegadas 1/\[Lambda].Representar en un histograma los valores obtenidos.*)


(* ::Input:: *)
(*mu=100;*)
(*lamda=80;*)
(*ro=lamda/mu;*)
(*listaExp=Table[RandomExp[lamda],{i,muestras}];*)
(*(*Histogram[listaExp, 100, "PDF"]*)*)
(*Show[Histogram[listaExp, 100, "PDF"], Plot[lamda*Exp[-lamda*t],{t,0,0.05}]]*)


(* ::Input:: *)
(*Mean[listaExp]*)
(*1/lamda//N*)


(* ::Text:: *)
(*Como vemos, la funci\[OAcute]n de densidad de probabilidad obtenida a partir de los valores generados mediante la funci\[OAcute]n RandomExp se acerca bastante a la funci\[OAcute]n de densidad de probabilidad de una distribuci\[OAcute]n exponencial. As\[IAcute] mismo, mencionar que la media de los valores obtenidos se aproxima a 1/\[Lambda], que era lo que se esperaba conseguir.*)
(**)
(*Destacar que cuantos m\[AAcute]s valores se utilicen para calcular la densidad de probabilidad de cada una de las distribuciones, el resultado m\[AAcute]s se parecer\[AAcute] al te\[OAcute]rico.*)
(**)


(* ::Subtitle:: *)
(*Parte segunda*)


(* ::Text:: *)
(*4. Desarrollar un simulador de una cola M/M/1 con tasa \[Lambda] de llegadas y \[Mu] de servicio.Representar en un diagrama que evolucione en el tiempo el n\[UAcute]mero de usuarios en el sistema*)


(* ::Input:: *)
(*mu=100;*)
(*lamda=80;*)
(*ro=lamda/mu;*)
(*muestras=10000;*)
(*InterArrivalsTime=Table[RandomExp[lamda],muestras];*)


(* ::Text:: *)
(*Las llegadas de la cola M/M/1 forman un proceso poissoniano. Es decir, las llegadas forman un proceso estoc\[AAcute]stico cuya particularidad es que el tiempo entre llegadas es independiente del resto de tiempos entre llegadas, y adem\[AAcute]s, estos siguen una distribuci\[OAcute]n exponencial. Por tanto, al generar valores aleatorios mediante la funci\[OAcute]n RandomExp lo que realmente estamos generando no es m\[AAcute]s que una lista que contiene la diferencia de tiempos entre una llegada y la anterior. Para conseguir los tiempos de llegada absolutos, que realmente es lo que nos interesa, se han de sumar en cada instante de tiempo todos los tiempos entre llegadas hasta ese momento.*)


(* ::Input:: *)
(*ArrivalsTime=Accumulate[InterArrivalsTime];*)


(* ::Input:: *)
(*ServTime=Table[RandomExp[mu], muestras];*)


(* ::Input:: *)
(*FifoSchedulling[arrivals_,service_]:=Module[{n,checkTime},n=1;checkTime=arrivals[[1]];*)
(*Map[(If[checkTime>=#,checkTime+=service[[n++]],checkTime=#+service[[n++]]])&,arrivals]]*)


(* ::Text:: *)
(*La funci\[OAcute]n FifoSchedulling permite calcular el tiempo en el que salen cada uno de los paquetes. A la funci\[OAcute]n se le pasan los tiempos de llegada de los paquetes y el tiempo que tardan en servirse. Despu\[EAcute]s, a trav\[EAcute]s de la variable checkTime se va calculando el tiempo en el que sale cada uno de los paquetes. En cada iteraci\[OAcute]n se compara si la cola esta libre o no. Si la cola se encontraba libre, la variable checkTime toma el valor de la suma del instante en el que se ha dado la llegada y el tiempo que se tarda en servir dicha llegada. Por el contrario, si se encontraba ocupada, el paquete de la iteraci\[OAcute]n en la que nos encontramos se comenzar\[AAcute] a servir tras acabar de servir el que ya se encontraba en la cola. Es decir, el paquete saldr\[AAcute] en el instante checkTime+tiempo de servir la nueva llegada.*)
(**)


(* ::Input:: *)
(*Departu=FifoSchedulling[ArrivalsTime, ServTime];*)


(* ::Input:: *)
(*ListStepPlot[{ArrivalsTime[[1;;5]], Departu[[1;;5]]}, AxesLabel->{Usuarios, Tiempo}, PlotLegends->{"Arrivals","Departures"}]*)


(* ::Text:: *)
(*Tal y como se puede observar, la grafica anterior tiene los usuarios en el eje x y el tiempo en el eje y, sin embargo, a nosotros nos interesa mostrarlos al rev\[EAcute]s.Para darle la vuelta, creamos una funci\[OAcute]n que coja el array de tiempos y con cada uno de los elementos genere una lista de dos elementos, {tiempo, usuarios en ese instante}.*)


(* ::Input:: *)
(*PointStair[array_]:= *)
(*Module[{n=0},*)
(*Map[{#,n++}&,array]];*)


(* ::Text:: *)
(*Las siguientes dos graficas muestran, a lo largo del tiempo, los eventos que se van dando tanto en las llegadas como en las salidas.Tal y como veremos a continuaci\[OAcute]n, cruzando la informaci\[OAcute]n de las dos l\[IAcute]neas representadas en las graficas se puede obtener el tiempo de espera que ha sufrido cada uno de los usuarios en el sistema. Concretamente, dicho tiempo de espera no es m\[AAcute]s que la diferencia de tiempos que existe entre cada una de las paralelas que se observan en las gr\[AAcute]ficas.*)


(* ::Input:: *)
(*ListStepPlot[{PointStair[ArrivalsTime][[1;;5]], PointStair[Departu][[1;;5]]}, AxesLabel->{Tiempo, Usuarios}, PlotLegends->{"Arrivals","Departures"}]*)
(**)


(* ::Input:: *)
(*Manipulate[ListStepPlot[{PointStair[ArrivalsTime][[origin;;origin+width]],PointStair[Departu][[origin;;origin+width]]}, AxesLabel->{Tiempo, Usuarios}, PlotLegends->{"Arrivals","Departures"}],{origin,1,1000-width,1},{width,10,If[muestras-origin> 0, muestras-origin, 10],1}]*)


(* ::Input:: *)
(*CreateEventList[list_, value_]:=Map[{#,value} &, list];*)


(* ::Input:: *)
(*NumUsers[list_]:= Module[{n=0,lastTime=0},Flatten[Map[{{lastTime,n},{lastTime=#[[1]],If[#[[2]]==1,n++,n--]}}&,list],1]]*)


(* ::Input:: *)
(*ArrivalsEvent=CreateEventList[ArrivalsTime, 1];*)
(*DepartureEvent=CreateEventList[Departu, -1];*)
(*ListaEventos=Sort[Join[ArrivalsEvent, DepartureEvent]];*)
(*usuarios=NumUsers[ListaEventos];*)


(* ::Text:: *)
(*Esta grafica muestra la evoluci\[OAcute]n en el tiempo de los usuarios del sistema.Como vemos, con los par\[AAcute]metros establecidos, en un mismo instante de tiempos hemos llegado a tener un n\[UAcute]mero m\[AAcute]ximo de 18 usuarios.*)


(* ::Input:: *)
(*ListLinePlot[usuarios, AxesLabel->{Tiempo, Usuarios}]*)


(* ::Input:: *)
(*Manipulate[ListLinePlot[usuarios[[origin;;origin+width]],AxesLabel->{Tiempo, Usuarios}],{origin,1,Length[usuarios]-width,1},{width,10,If[Length[usuarios]-origin> 0, Length[usuarios]-origin, 10],1}]*)


(* ::Text:: *)
(*5.Representar el tiempo medio de espera en el sistema normalizado por \[Mu] para diferentes valores de \[Rho]. Hacerlo con la curva te\[OAcute]rica y representar los puntos obtenidos en las simulaciones.*)


(* ::Input:: *)
(*curvaTeorica=Plot[1/(1-ro), {ro,0,1}, AxesOrigin->{0,0}, AxesLabel->{Ro, muEt[t]}, PlotLegends->{"Teorica"}];*)


(* ::Input:: *)
(*GetTiempoMedio[]:=*)
(*Module[{mu, lamda, ro, arrivals, services,departures, meanTime,nmuestras},*)
(**)
(*	mu=100;*)
(*	nmuestras=10000;*)
(*	lamda=Table[i,{i,1,mu}];*)
(*	Map[*)
(*( *)
(*ro=#/mu//N;*)
(*arrivals=Accumulate[Table[RandomExp[#],nmuestras]];*)
(*services=Table[RandomExp[mu],nmuestras];*)
(*departures=FifoSchedulling[arrivals, services];*)
(*meanTime=Mean[departures-arrivals];*)
(*{ro, meanTime*mu}*)
(*)*)
(*&,lamda]*)
(*]*)
(**)


(* ::Input:: *)
(*curvaPractica=ListPlot[GetTiempoMedio[], {AxesLabel->{Ro, muEt[t]}, PlotLegends->{"Practica"}, PlotStyle->Red}];*)


(* ::Text:: *)
(*El tiempo medio de espera simulado se calcula como la media de la diferencia de tiempos en cada instante de las salidas y las llegadas.Tal y como ocurr\[IAcute]a en casos anteriores, cuantas m\[AAcute]s muestras se utilicen el valor simulado se aproxima m\[AAcute]s al te\[OAcute]rico.En mi caso, he utilizado un total de 10000 muestras con las cuales he conseguido una aproximaci\[OAcute]n bastante precisa.*)


(* ::Input:: *)
(*Show[curvaTeorica, curvaPractica]*)


(* ::Subtitle:: *)
(*Parte tercera*)


(* ::Text:: *)
(*6.Representar las probabilidades de estado pn de la cola M/M/1 te\[OAcute]ricas, as\[IAcute] como las obtenidas por simulaci\[OAcute]n para diferentes puntos de ensayo.Comprobar si esa distribuci\[OAcute]n coincide con la visualizada seg\[UAcute]n la propiedad PASTA en los tiempos de llegada.*)


(* ::Text:: *)
(*La probabilidad simulada de cada estado se calcula como el tiempo total que el sistema ha estado en dicho estado, divido entre el tiempo total. Por el contrario, si deseamos calcular dichas probabilidades haciendo uso de la propiedad PASTA \[UAcute]nicamente habr\[IAcute]a que tener en cuenta los casos en los que se da un incremento de usuarios en el sistema, y el n\[UAcute]mero de veces que se ha dado dicha situaci\[OAcute]n.*)
(**)
(*Dicho de otra manera, para calcular la probabilidad de cada estado mediante PASTA, se ha de tener un contador por estado el cual se incremente cada vez que dicho estado pasa a un estado que indique una mayor cantidad de usuarios, y un contador general que cuente cada vez que se incremente uno de los contadores de estado. Hecho esto, bastar\[IAcute]a con dividir cada uno de los contadores de estado entre el valor del contador general.*)
(**)
(*Por \[UAcute]ltimo, las probabilidades de estado te\[OAcute]ricas se calculan como (1 - ro)*(ro^n) donde n es el estado del cual se desea calcular la probabilidad y ro es lamda/mu.*)


(* ::Input:: *)
(*ProbEstadoPrac[usuario_]:=*)
(*Module[ {arrayTmp, arrayEstados, maxEstados},*)
(*maxEstados=Max[Map[(#[[2]]) &,usuario]]+1;*)
(*arrayEstados=Table[0,maxEstados];*)
(*arrayTmp=Partition[usuario,2];*)
(*Map[(arrayEstados[[(# [[1]][[2]]+1)]]+=(#[[2]][[1]]-#[[1]][[1]]))&, arrayTmp];*)
(*Return[arrayEstados/usuario[[-1]][[1]]]*)
(*]*)


(* ::Input:: *)
(*ProbEstadoPasta[usuario_]:=*)
(*Module[ {arrayTmp, arrayEstados, maxEstados, valorAnterior, contadorEstados},*)
(*maxEstados=Max[Map[(#[[2]]) &,usuario]]+1;*)
(*contadorEstados=0;*)
(*arrayEstados=Table[0,maxEstados];*)
(*arrayTmp=Partition[usuario,2];*)
(*valorAnterior=usuario[[1]][[2]];*)
(*Map[( *)
(*If[#[[1]][[2]]> valorAnterior,*)
(*(arrayEstados[[valorAnterior+1]]+=1; *)
(*valorAnterior=#[[1]][[2]];*)
(* contadorEstados+=1;)*)
(*, valorAnterior=#[[1]][[2]]]*)
(*	)&, arrayTmp];*)
(*Return[arrayEstados/contadorEstados]*)
(*]*)


(* ::Input:: *)
(*ProbEstadoTeorico[lamda_, mu_, nestados_]:=*)
(*Module[{array,ro0},*)
(*ro0=lamda/mu;*)
(*array=Table[i,{i,0,nestados}];*)
(*Map[*)
(*( *)
(*(1-ro0)*(ro0^#)*)
(*)*)
(**)
(*&, array]*)
(*]*)
(**)


(* ::Input:: *)
(*probPractica=ProbEstadoPrac[usuarios];*)


(* ::Input:: *)
(*probPasta=N [ProbEstadoPasta[usuarios]];*)


(* ::Input:: *)
(*probTeorica=N[ProbEstadoTeorico[lamda, mu, Length[probPractica]]];*)


(* ::Text:: *)
(*En la siguiente grafica se puede observar c\[OAcute]mo tanto la distribuci\[OAcute]n obtenida mediante la propiedad PASTA como la obtenida mediante los valores de la simulaci\[OAcute]n se asemejan bastante a la distribuci\[OAcute]n te\[OAcute]rica.*)


(* ::Input:: *)
(*ListPlot[{probTeorica, probPractica, probPasta}, PlotLegends->{"Teorica","Practica", "PASTA"}]*)


(* ::Subtitle:: *)
(*Parte cuarta*)


(* ::Text:: *)
(*7. Preparar las gr\[AAcute]ficas de rendimiento de colas vistas en Teor\[IAcute]a de la informaci\[OAcute]n para los casos espec\[IAcute]ficos que se elijan. Revisar la teor\[IAcute]a.*)


(* ::Text:: *)
(*En este \[UAcute]ltimo apartado he optado por simular una cola M/M/2 formada por un servidor con tasa de servicio mu y otro con tasa de servicio 2mu. Se ha de destacar que en el caso en el cual ambos servidores se encuentren vac\[IAcute]os el paquete lo servir\[AAcute] el servidor 1. Es decir, el servidor 1 tiene mayor prioridad.*)


(* ::Input:: *)
(*ColaMM2[arrivals_,service1_, service2_]:=*)
(*Module[{n, checkTime1, checkTime2},*)
(*n=1;*)
(*checkTime1=arrivals[[1]];*)
(*checkTime2=arrivals[[1]];*)
(*Map[( *)
(*If[ checkTime1<=#, checkTime1=#+service1[[n++]], If[checkTime2<=#, checkTime2=#+service2[[n++]],If[checkTime1<=checkTime2, checkTime1+=service1[[n++]],checkTime2+=service2[[n++]]]]]*)
(*)&,arrivals]]*)


(* ::Input:: *)
(*ArrivalsTime;*)
(*ServTime1=Table[RandomExp[mu], muestras];*)
(*ServTime2=Table[RandomExp[2*mu], muestras];*)
(*DepartuMM2=Sort[ColaMM2[ArrivalsTime, ServTime1, ServTime2]];*)


(* ::Input:: *)
(*ListStepPlot[{PointStair[ArrivalsTime][[1;;50]],PointStair[DepartuMM2][[1;;50]]}, AxesLabel->{Tiempo, Usuarios}, PlotLegends->{"Arrivals","Departures"}]*)


(* ::Input:: *)
(*Manipulate[ListStepPlot[{PointStair[ArrivalsTime][[origin;;origin+width]],PointStair[DepartuMM2][[origin;;origin+width]]}, AxesLabel->{Tiempo, Usuarios}, PlotLegends->{"Arrivals","Departures"}],{origin,1,1000-width,1},{width,10,If[muestras-origin> 0, muestras-origin, 10],1}]*)


(* ::Input:: *)
(*ArrivalsEventMM2=CreateEventList[ArrivalsTime, 1];*)
(*DepartureEventMM2=CreateEventList[DepartuMM2, -1];*)
(*ListaEventosMM2=Sort[Join[ArrivalsEventMM2, DepartureEventMM2]];*)
(*usuariosMM2=NumUsers[ListaEventosMM2];*)


(* ::Text:: *)
(**)
(*Tal y como podemos observar en la siguiente gr\[AAcute]fica, el n\[UAcute]mero de usuarios m\[AAcute]ximos del sistema se ha visto reducido considerablemente. Con una cola M/M/1 ten\[IAcute]amos aproximadamente 18, mientras que con una cola M/M/2 tenemos 6. Esto es debido a que al tener 2 servidores, es posible servir dos paquetes en paralelo, reduciendo de esta manera los tiempos de espera del sistema.*)
(**)


(* ::Input:: *)
(*ListLinePlot[usuariosMM2]*)


(* ::Input:: *)
(*Manipulate[ListLinePlot[usuariosMM2[[origin;;origin+width]]],{origin,1,Length[usuariosMM2]-width,1},{width,10,If[Length[usuariosMM2]-origin> 0, Length[usuariosMM2]-origin, 10],1}]*)


(* ::Input:: *)
(*probPracticaMM2=ProbEstadoPrac[usuariosMM2];*)


(* ::Text:: *)
(**)
(*A continuaci\[OAcute]n, se puede observar el numero maximo de usuarios para una cola M/M/1 y una cola M/M/2. Tambien se puede observar como se reduce dr\[AAcute]sticamente el numero maximo en la cola M/M/2.*)


(* ::Input:: *)
(*Show[ListPlot[{probPractica, probPracticaMM2}, PlotRange->{{0.5,25.5},{0,0.55}}],ListLinePlot[{probPractica, probPracticaMM2}, {PlotLegends->{"M/M/1","M/M/2"}, PlotRange->{{0.5,25.5},{0,0.55}}}]]*)
