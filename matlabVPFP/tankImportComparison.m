%compare data import from .nex file with tdtbin2mat.m from TDT's Matlab APK

tdtData= TDTbin2mat('H:\TDT Photometry tanks\FP_Mag_Training_withTTL_TDT2-200107-134843\GAD-VP-VTA-2-210222-123646');

nexData= readNexFile('H:\Photometry nex files\GAD-VP-VTA-FP\mag training\GAD-VP-VTA-2-210222-123646.nex');


%trying to see what is in fi1d-
%very memory intensive, just sin waves used to modulate LEDs
%- These data are saved under the store name
% '{Fi}{N}d' at the RZ processor acquisition rate. These data are the
% sine waves used to modulate the light driver channels. For n light
% drivers, there will be n channels of light driver waveforms. These
% are not saved by default to save data space
% figure(); title('fi1d'); plot(tdtData.streams.Fi1d.data(1,1:200000));


%Here are the actual frequency, level, & offset settings:
%this isn't in the .nex file, but it is in the TDTbin2mat data

driverSettings= tdtData.scalars.Fi1i.data;

%there is some metadata in the TDTbin2mat data that is not in the .nex file
metadata= tdtData.info;

%everything else seems pretty much the same

%not sure why fi1c is not present? (online calculations e.g. df/f)


%trying TDTfft.m to see power spectra
fftBlue= TDTfft(tdtData.streams.Dv3B,1, 'SPECPLOT',1);
fftPurple= TDTfft(tdtData.streams.Dv4B,1);