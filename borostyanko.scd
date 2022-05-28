
// hangszerver
s.boot;

//////////////////////////////////////////////////////////////////////////////////////////
// HANG
(
SynthDef.new(\hang,{
	arg frek1 = 100,
	frek2 = 1,
	impulseFrek = 1,
	attack = 0.1,
	release = 0.5,
	fold = 0.1,
	filt = 2000,
	delay1 = 0.2,
	delay2 = 1,
	scale = 1,
	fbszorzo = 1,
	mozgas = 0,
	gain = 1;


	frek1 = LPF.kr(frek1,0.1);

	frek2 = frek1*frek2;

	mozgas = LFTri.kr(0.1,mul:mozgas*0.05,add:1);

	gain = LPF.kr(gain,10);
	scale = LPF.kr(scale,0.2);

	delay1 = LPF.kr(delay1,0.5)*scale * mozgas;
	delay2 = LPF.kr(delay2,0.5)*scale * mozgas;

	e = EnvGen.ar(Env.perc(attack,release),Impulse.ar(impulseFrek+LFNoise0.ar(0.7),0.1));
	i = SinOsc.ar([frek1,frek2])*e*gain;
	i = i + (LocalIn.ar(2).sum/4) + (LocalIn.ar(2)/4);
	i = HPF.ar(LPF.ar(i, filt),20.0);
	i = DelayC.ar(i,1.5,[delay1-DelayC.ar(i/10000,0.1,0.01),delay2]);
	LocalOut.ar(sin(i*pi*fold)*fbszorzo);

	Out.ar(0,i/5);
}).add;
)

~hang = Synth.new(\hang);

~hang.free;


//////////////////////////////////////////////////////////////////////////////////////////
// MIDI
MIDIClient.init;
MIDIIn.connectAll;

(
MIDIdef.cc(\ccT,{
	arg val, nn;
	//[val, nn].postln;

	//if(nn == 0,{~hang.set(\frek1, val.midicps ) });
	if(nn == 1,{~hang.set(\frek2,  (val+30)/120) });

	if(nn == 2,{~hang.set(\attack, ((val)/128)) });
	if(nn == 3,{~hang.set(\release, ((val)/128)) });

	if(nn == 4,{~hang.set(\fold, 0.1+((val+1)/128)) });
	if(nn == 5,{~hang.set(\filt, 10+(((val/127)**2)*15000)) });

	if(nn == 6,{~hang.set(\delay1, 0.0001+(val/127*1.2))});
	if(nn == 7,{~hang.set(\delay2, 0.0001+(val/127*1)) });

	if(nn == 104,{~hang.set(\scale, 0.01+(val/127*2)) });
	if(nn == 89,{~hang.set(\impulseFrek, (((val+10)/137)**3)*200) });

	if(nn == 0,{~hang.set(\gain, (((val+10)/137)**2)*2) });
	if(nn == 90,{~hang.set(\fbszorzo, (val/100) )});

	if(nn == 91,{~hang.set(\mozgas, (val/100) )});

});

MIDIdef.noteOn(\note, {

	arg vel, nn;
	("Note: " + nn.midicps).postln;
	~hang.set(\frek1, nn.midicps );
})

)