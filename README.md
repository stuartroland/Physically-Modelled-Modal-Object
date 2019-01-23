# Physically-Modelled-Modal-Object
A physically-modelled virtual-instrument of a modal bowl

For this project I recorded a metal bowl I found that had a really interesting sound to it and created a physically modelled virtual instrument out of it. To do so I used Perry R. Cook's ChucK script to analyze the recording I made and give me the the frequencies and their respective amplitudes that made up the modal sound of the bowl being struck. Then I made the physical model by setting some resonant filters to the mode's frequencies, amplitudes, and T60s and routed in an impulse to excite the filters and simulate a strike. Finally I made an array of these modeled bowls, retuned them, and set up an algorithmic song for them to play out, which will vary every time its run.

## Examples
I included the original recording of the bowl I made for reference as well as a recording of the generative piece using the physical model. 

## Running the Code
#### Installing ChucK
To run this code, you will need to install ChucK, the strongly-timed audio programming languange that this project was created in. ChucK can be downloaded from http://chuck.cs.princeton.edu/ where you will also find installation instructions. Note that ChucK can be a little finicky to install. On Windows, the executable downloads as a .man file (no idea what to do with that file type), which I have had to manually rename to a .zip file (a rather dangerous way to deal with files I admit), unzip, then install with the executible. Installing on Linux is another challenge, as there are 3 installation methods, each of which has worked unreliably for me, but once you get one working it's fine. I have no personal experience with installing on Macs, though I would guess this would actually be the most stable and straightforward platform, as I believe the developers primarily write on and develop for Macs.
#### Running the Examples
Once ChucK is installed, you can just load up "Physical Model Resynthesis.ck" and it will play out a random version of the algorithmic song I made with the PM bowl instruments.
