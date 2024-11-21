# Microphone-Sound-Enhancement
To be able to hear what a person says on a stage or in a conference room, microphones can be used to enhance and amplify the voice of the speaker. However, if
there is only one loudspeaker that gives output, the immersion might be ruined for
the listeners since the sound does not come directly from the speaker’s voice on stage.
In this project, we investigate the possibility of a system that gives the audience
the illusion that the sound is coming directly from the speaker’s voice and not from
some loudspeaker somewhere else. The system that the project developed consisted
of four static microphones which gave input to a FPGA which selected and processed
the incoming raw data and gave the output to a static loudspeaker. The project
team developed the system by connecting and programming peripheral devices to
the FPGA to programming the FPGA to process the incoming microphone data.
The end product of the system was able to do some simple selection of the microphones where the input microphone that had the highest amplitude was chosen.
Also, the raw microphone data was processed through several filters and later amplified to a speaker. A further scope of the project was found to be to implement
more filters and refine the channel selection process to be able to select and combine data from several channels at once.
