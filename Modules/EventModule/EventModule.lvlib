<?xml version='1.0' encoding='UTF-8'?>
<Library LVVersion="14008000">
	<Property Name="NI.Lib.FriendGUID" Type="Str">841ffe9f-36d6-4063-aa33-544391a85f7f</Property>
	<Property Name="NI.Lib.Icon" Type="Bin">&amp;!#!!!!!!!)!"1!&amp;!!!-!%!!!@````]!!!!"!!%!!!*3!!!*Q(C=\:1^5C."$%9`+)+N=D1&amp;"["]"58E0A+_AK\AF.!JI=,&gt;+C=/NT:B@16&gt;Q6@Q&amp;99X02JD#("ANGI$ON%Q]UENP@ZR3[X^E'\5HWOT4^M8_)=;L1_R1XA`$BO`_Z)G8V`3^/D(W+/`_KF`.DPG05XW.L\`[(^8`],ZH7P[N(X\P`W8_=]@P[@TB`4@.OGKE7+*"?;9N&gt;HVC:\IC:\IC:\IA2\IA2\IA2\IDO\IDO\IDO\IBG\IBG\IBG\IL;-,8?B#:V73YEGB*'G3)!E'2=EDY5FY%J[%BU]F0!F0QJ0Q*$S%+/&amp;*?"+?B#@B9:A3HI1HY5FY%BZ3.:*M(2W?B)@U#HA#HI!HY!FY++G!*Q!)CA7*AS2A+(!',Q&amp;0Q"0Q]+K!*_!*?!+?A!?X!J[!*_!*?!)?BL26C59T&gt;(2Y3#/(R_&amp;R?"Q?BY@5=HA=(I@(Y8&amp;Y+#?(R_&amp;R)*S#4H)1Z!RS!JQ0B]@BY:]=(I@(Y8&amp;Y("Z=&lt;9?]L=R!-X2U?!Q?A]@A-8A-(F,)Y$&amp;Y$"[$R_!BL1Q?A]@A-8A-(EL*Y$&amp;Y$"Y$R#B+?2H*D)&amp;'E#%900SVUW*NF[+27/PVURQ0KOI!KA[7[M#I$I*KAV5&lt;J^I1V5+L&amp;F#V-+I*KS;C!F166C65"?L!=Y`NM#WWRF&lt;9%FNA=[Q&lt;BHZRY/&amp;QU([`VW[XUX;\V8K^VGKVUH+ZV'+RU(Q_6^&gt;VR^PKHD[WK_F??O*^ML]PNQ_`HP^M@D]`&lt;HZW&gt;ZO8\P:B]HW-P&gt;4'?_F`O"NVL@\EGG?.8A&amp;&lt;6'6H!!!!!!</Property>
	<Property Name="NI.Lib.SourceVersion" Type="Int">335577088</Property>
	<Property Name="NI.Lib.Version" Type="Str">1.0.0.0</Property>
	<Property Name="NI.LV.All.SourceOnly" Type="Bool">false</Property>
	<Item Name="Friends List" Type="Friends List">
		<Item Name="PmuImpairTestBed.lvlib" Type="Friended Library" URL="../../../TestBeds/PmuImpairTestBed/PmuImpairTestBed.lvlib"/>
		<Item Name="NetworkImpairTestBed.lvlib" Type="Friended Library" URL="../../../TestBeds/NetworkImpairTestBed/NetworkImpairTestBed.lvlib"/>
		<Item Name="FlagImpairTestBed.lvlib" Type="Friended Library" URL="../../../TestBeds/FlagImpairTestBed/FlagImpairTestBed.lvlib"/>
		<Item Name="Framework.lvlib:Bus.lvclass" Type="Friended Library" URL="../../../Framework/Bus_class/Bus.lvclass"/>
		<Item Name="Framework.lvlib" Type="Friended Library" URL="../../../Framework/Framework.lvlib"/>
		<Item Name="Bus_class.lvlib:Bus.lvclass" Type="Friended Library" URL="../../../Framework/Bus_class/Bus.lvclass"/>
		<Item Name="BusController.lvlib" Type="Friended Library" URL="../../../Framework/BusController/BusController.lvlib"/>
		<Item Name="Test_MultiBus.vi" Type="Friended VI" URL="../../../TestBeds/Test_MultiBus/Test_MultiBus.vi"/>
		<Item Name="main.vi" Type="Friended VI" URL="../../../main.vi"/>
	</Item>
	<Item Name="Private" Type="Folder">
		<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
	</Item>
	<Item Name="Protected" Type="Folder">
		<Property Name="NI.LibItem.Scope" Type="Int">4</Property>
		<Item Name="Broadcast" Type="Folder">
			<Item Name="clBroadcastEvents.ctl" Type="VI" URL="../Protected/Broadcasts/clBroadcastEvents.ctl"/>
			<Item Name="DestroyBroadcastEvents.vi" Type="VI" URL="../Protected/Broadcasts/DestroyBroadcastEvents.vi"/>
			<Item Name="DidInit.vi" Type="VI" URL="../Protected/Broadcasts/DidInit.vi"/>
			<Item Name="DidStop.vi" Type="VI" URL="../Protected/Broadcasts/DidStop.vi"/>
			<Item Name="GetEvtReports.vi" Type="VI" URL="../Protected/Broadcasts/GetEvtReports.vi"/>
			<Item Name="GetEvtSignal.vi" Type="VI" URL="../Protected/Broadcasts/GetEvtSignal.vi"/>
			<Item Name="ObtainBroadcastEvents.vi" Type="VI" URL="../Protected/Broadcasts/ObtainBroadcastEvents.vi"/>
			<Item Name="ReadBusNumber.vi" Type="VI" URL="../Protected/Broadcasts/ReadBusNumber.vi"/>
			<Item Name="ReadEvtConfig.vi" Type="VI" URL="../Protected/Broadcasts/ReadEvtConfig.vi"/>
			<Item Name="ReadEvtParams.vi" Type="VI" URL="../Protected/Broadcasts/ReadEvtParams.vi"/>
			<Item Name="ReadPathToPlugin.vi" Type="VI" URL="../Protected/Broadcasts/ReadPathToPlugin.vi"/>
			<Item Name="ReadTimeArray.vi" Type="VI" URL="../Protected/Broadcasts/ReadTimeArray.vi"/>
			<Item Name="ReportError.vi" Type="VI" URL="../Protected/Broadcasts/ReportError.vi"/>
			<Item Name="StatusUpdate.vi" Type="VI" URL="../Protected/Broadcasts/StatusUpdate.vi"/>
		</Item>
		<Item Name="Queue" Type="Folder">
			<Item Name="Dequeue.vi" Type="VI" URL="../Protected/Queue/Dequeue.vi"/>
			<Item Name="Enqueue.vi" Type="VI" URL="../Protected/Queue/Enqueue.vi"/>
			<Item Name="ObtainQueue.vi" Type="VI" URL="../Protected/Queue/ObtainQueue.vi"/>
		</Item>
		<Item Name="Requests" Type="Folder">
			<Item Name="clRequestEvents.ctl" Type="VI" URL="../Protected/Requests/clRequestEvents.ctl"/>
			<Item Name="DestroyRequestEvents.vi" Type="VI" URL="../Protected/Requests/DestroyRequestEvents.vi"/>
			<Item Name="GetEvtReportsRequest.vi" Type="VI" URL="../Protected/Requests/GetEvtReportsRequest.vi"/>
			<Item Name="GetEvtSignalRequest.vi" Type="VI" URL="../Protected/Requests/GetEvtSignalRequest.vi"/>
			<Item Name="LoadPluginRequest.vi" Type="VI" URL="../Protected/Requests/LoadPluginRequest.vi"/>
			<Item Name="ObtainRequestEvents.vi" Type="VI" URL="../Protected/Requests/ObtainRequestEvents.vi"/>
			<Item Name="ReadBusNumberRequest.vi" Type="VI" URL="../Protected/Requests/ReadBusNumberRequest.vi"/>
			<Item Name="ReadEvtConfigRequest.vi" Type="VI" URL="../Protected/Requests/ReadEvtConfigRequest.vi"/>
			<Item Name="ReadEvtParamsRequest.vi" Type="VI" URL="../Protected/Requests/ReadEvtParamsRequest.vi"/>
			<Item Name="ReadPathToPluginRequest.vi" Type="VI" URL="../Protected/Requests/ReadPathToPluginRequest.vi"/>
			<Item Name="ReadTimeArrayRequest.vi" Type="VI" URL="../Protected/Requests/ReadTimeArrayRequest.vi"/>
			<Item Name="ShowPanelRequest.vi" Type="VI" URL="../Protected/Requests/ShowPanelRequest.vi"/>
			<Item Name="StopRequest.vi" Type="VI" URL="../Protected/Requests/StopRequest.vi"/>
			<Item Name="WriteBusNumberRequest.vi" Type="VI" URL="../Protected/Requests/WriteBusNumberRequest.vi"/>
			<Item Name="WriteEvtConfigRequest.vi" Type="VI" URL="../Protected/Requests/WriteEvtConfigRequest.vi"/>
			<Item Name="WriteEvtParamsRequest.vi" Type="VI" URL="../Protected/Requests/WriteEvtParamsRequest.vi"/>
			<Item Name="WriteTimeArrayRequest.vi" Type="VI" URL="../Protected/Requests/WriteTimeArrayRequest.vi"/>
		</Item>
		<Item Name="clEventType.ctl" Type="VI" URL="../Protected/clEventType.ctl"/>
		<Item Name="DestroyClone.vi" Type="VI" URL="../Protected/DestroyClone.vi"/>
		<Item Name="ErrorHandler.vi" Type="VI" URL="../Protected/ErrorHandler.vi"/>
		<Item Name="HandleExit.vi" Type="VI" URL="../Protected/HandleExit.vi"/>
	</Item>
	<Item Name="PublicAPI" Type="Folder">
		<Item Name="Arguments" Type="Folder">
			<Item Name="Broadcasts" Type="Folder">
				<Item Name="clDidInit.ctl" Type="VI" URL="../PublicAPI/Arguments/Broadcasts/clDidInit.ctl"/>
				<Item Name="clErrorRpt.ctl" Type="VI" URL="../PublicAPI/Arguments/Broadcasts/clErrorRpt.ctl"/>
				<Item Name="clStatUpdate.ctl" Type="VI" URL="../PublicAPI/Arguments/Broadcasts/clStatUpdate.ctl"/>
			</Item>
			<Item Name="Messages" Type="Folder">
				<Item Name="clMessage.ctl" Type="VI" URL="../PublicAPI/Arguments/Messages/clMessage.ctl"/>
			</Item>
			<Item Name="Requests" Type="Folder">
				<Item Name="clStopArgument.ctl" Type="VI" URL="../PublicAPI/Arguments/Requests/clStopArgument.ctl"/>
				<Item Name="dblEvtParams.ctl" Type="VI" URL="../PublicAPI/Arguments/Requests/dblEvtParams.ctl"/>
				<Item Name="dblTimeArray.ctl" Type="VI" URL="../PublicAPI/Arguments/Requests/dblTimeArray.ctl"/>
			</Item>
		</Item>
		<Item Name="Broadcasts" Type="Folder">
			<Item Name="ObtainBroadcastForRegistration.vi" Type="VI" URL="../PublicAPI/Broadcasts/ObtainBroadcastForRegistration.vi"/>
		</Item>
		<Item Name="StartClone.vi" Type="VI" URL="../PublicAPI/StartClone.vi"/>
		<Item Name="StopClone.vi" Type="VI" URL="../PublicAPI/StopClone.vi"/>
	</Item>
	<Item Name="Test" Type="Folder">
		<Item Name="IniFiles.vi" Type="VI" URL="../Test/IniFiles.vi"/>
		<Item Name="InitSelectRing.vi" Type="VI" URL="../Test/InitSelectRing.vi"/>
		<Item Name="TestInfo.ctl" Type="VI" URL="../Test/TestInfo.ctl"/>
		<Item Name="TestInfo.vi" Type="VI" URL="../Test/TestInfo.vi"/>
		<Item Name="UpdateSelectRing.vi" Type="VI" URL="../Test/UpdateSelectRing.vi"/>
	</Item>
	<Item Name="Main.vi" Type="VI" URL="../Main.vi"/>
	<Item Name="TestClone.vi" Type="VI" URL="../Test/TestClone.vi"/>
	<Item Name="TestRingdownEvent.vi" Type="VI" URL="../Test/TestRingdownEvent.vi"/>
</Library>
