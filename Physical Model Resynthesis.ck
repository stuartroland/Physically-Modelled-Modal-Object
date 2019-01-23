/*
Resynthesize the sound of a modal bowl by making a Physical Model (PM) from data extracted from a recording I made of striking the bowl.
This data was gathered with a program created by Perry R. Cook, "FFTFindModes.ck", included in the dependencies directory
Then, compose and play a generative song using an array of retuned bowls (which plays out differently each time)

Stuart Roland
*/

// Modal Resynthsis Class, uses ResonZ filters for modes
class ModalSynth extends Chubgraph {
    // frequency  ,  gain  , and time constants for each mode
    [[ 433.355713 , 0.191672 , 4.5 ],
    [ 479.113770 , 0.132200  , 4.0 ], 
    [ 931.311035 , 1.000000  , 7.0 ],
    [ 1025.518799 , 0.131265 , 5.5 ], 
    [ 1579.998779 , 0.084416 , 3.5 ], 
    [ 1851.855469 , 0.250820 , 3.1 ],   
    [ 3493.762207 , 0.103523 , 2.4 ],  
    [ 4083.233643 , 0.085112 , 2.2 ], 
    [ 4715.771484 , 0.023425 , 1.8 ],
    [ 6058.905029 , 0.004147 , 1.5 ],
    [ 8807.080078 , 0.005041 , 1.3 ],
    [ 10050.622559 , 0.005195 , 1.0]]
     @=> float modeData[][];

    // changed this so I didn't have to keep updating every time I wanted to add or remove modes
    // automatically gets the number of modes from the above array
    modeData.cap() => int NUM_MODES;
    ResonZ modes[NUM_MODES];
    Gain out;


// the impulse sound file that excites the model
SndBuf excite;
me.dir() + "Dependencies/Impulse.wav" => excite.read;
excite.samples() => excite.pos;
  
95.0 => excite.gain;

    for (int i; i < NUM_MODES; i++)  {
        excite => modes[i] => out;
        modeData[i][0] => modes[i].freq; // frequencies from data
        // set these automatically here, you can do better
        // changed this to take T60 vals from freqsNams array, using
        // values that I found by analyzing the sound with the rogram
        // Soniv Visualizer.
        // I also added a scalar so I could easily change the values for all T60s by the same
        // factor, since I was estimating the T60 off of a closer T30. 
        setQfromT60(modeData[i][2]*0.8,modeData[i][0]) => modes[i].Q;  
        modeData[i][1] => modes[i].gain;
    }

    fun float setQfromT60 (float tsixty, float centerFreq)  {  
        Math.pow(10.0,-3.0/(tsixty*second/samp)) => float rad;
        Math.log(rad) / -pi / (samp/second) => float BW;
        centerFreq / BW => float Q;
        return Q;
    }

    fun void whackIt()  {
        0 => excite.pos;    // set the impulse to play

    }
    
    fun void whackItRandom(float vel)  {
        for (int i; i < 10; i++)  {  // randomize the mode gains a bit
            vel*Math.random2f(modeData[i][1]/2,2*modeData[i][1]) => modes[i].gain;
        }
        whackIt();
    }

    fun void whackIt(float vel)  {
        for (int i; i < 10; i++)  {  // assume lots about spatial modes
            vel*Math.random2f(modeData[i][1]/2,2*modeData[i][1]) => modes[i].gain;
        }
        whackIt();
    }

    // overloaded function uses position (0-1.0) for mode gains
    //   makes gross assumption that modes are 1D spatial modes
    fun void whackIt(float vel, float position)  {
        for (int i; i < NUM_MODES; i++)  {
            modeData[i][0] => modes[i].freq;
            Math.sin(pi*(i+1)*position) => float temp;
            vel*temp*modeData[i][1] => modes[i].gain;
        }
        whackIt();
     }
     
     fun void whackIt(float pitch, float velocity, float position)  {
         for (int i; i < NUM_MODES; i++)  {
             pitch*modeData[i][0] => modes[i].freq;
             Math.sin(pi*(i+1)*position/NUM_MODES) => float temp;
             velocity*temp*modeData[i][1] => modes[i].gain;
         }
         whackIt();
     }
     
 }

 
// Composition  _____________________________________________________
 
// sound chain
10 => int numBowls;
 
ModalSynth bowl[numBowls];
 
Gain bowlGain => NRev rev => Gain master => dac;

for(0 => int b; b < numBowls; b++)
    {
        bowl[b].out => bowlGain;
    }
    
(1.0/4.0)::second => dur beattime;
0 => int total => int total2;
0 => int beatsLeft => int beatsLeft2; // beats until next note
 
3.0 => bowlGain.gain;
3.0 => master.gain;
0.14 => rev.mix;

    
// raga (scale) and tonic
[165.0,176.0,220.0,247.5,264.0] @=> float raga[]; 
[110.0,165.0,247.5,352.0,528.0] @=> float raga2[];
165.0 => float tonic;

    
// MAIN PROGRAM

// made modal bowl object for each tone in the scale / chord being played,
// so its not one bowl switching its pitch constantly, but multiple objects being played
// sounds more natural as more energy is added to each system, rather than fast switches 
// between one sound object and the next (each with diff pitches)


// SEQUENCING the musical sections_________________________________________________
now + 20::second => time sec2;
now + 35::second => time sec3;
now + 38.5::second => time sec4;
now + 40::second => time end;

fun void section2(dur len)
{
    now => time start;
    while( now < start+len )
    {
        Math.random2(0,raga.cap()-1) => int thisNote2;
        raga2[thisNote2]*(1.0/2) => float freq2;
        if( beatsLeft2 == 0 ) // time for next note
        {
            bowl[thisNote2+raga.cap()].whackIt(freq2/tonic,Math.random2f(0.35,0.8), Math.random2f(0.2,0.3)); // bowl.whackIt
            Math.random2(1,2) => beatsLeft2; // beats until next note
        }
        beattime*(0.5) => now;
        1 +=> total2;
        1 -=> beatsLeft2;
    }
}

// MAIN LOOP________________________________________________________________________
// where the song is actually played
while( now < end )
{
    // part played in parts 1 and 2
    if( now < sec3)
    {
        Math.random2(0,raga.cap()-1) => int thisNote;
        raga[thisNote]*(1.0/2) => float freq;
        
        if( beatsLeft == 0 ) // time for next note
        {
            bowl[thisNote].whackIt(freq/tonic,Math.random2f(0.5,0.9), Math.random2f(0.15,0.5)); // bowl.whackIt
            Math.random2(1,3) => beatsLeft; // beats until next note
        }
     beattime => now;
        1 +=> total;
        1 -=> beatsLeft;
    }
    // start simultaneous part that comes in during section 2 (the "chorus")
    if (now == sec2)
        {
            spork ~ section2(15::second);
        }
    // start section 3
    if ((now >= sec3)&&(now < sec4))
    {
        Math.random2(0,raga.cap()-1) => int thisNote;
        raga[thisNote]*(1.0/2) => float freq;
        if( beatsLeft == 0 ) // time for next note
        {
            bowl[thisNote].whackIt(freq/tonic,Math.random2f(0.35,0.7), Math.random2f(0.2,0.3)); // bowl.whackIt
            Math.random2(1,2) => beatsLeft; // beats until next note
        }
     beattime*2 => now;
        1 +=> total;
        1 -=> beatsLeft;
    }
    // final section
    if (now >= sec4)
        {
        2 => int thisNote;
        (Math.random2(1,3)/2) + 1 => int octave;
        raga[thisNote]*(1.0/(2*octave)) => float freq;
        if( beatsLeft == 0 ) // time for next note
        {
            bowl[5+octave].whackIt(freq/tonic,Math.random2f(0.7,0.9), Math.random2f(0.2,0.3)); // bowl.whackIt
            Math.random2(1,2)*2 => beatsLeft; // beats until next note
        }
     beattime*2 => now;
        1 +=> total;
        1 -=> beatsLeft;
    }
}

// add time for last note to ring out
8::second => now;
 

 
 
