%2.8.19 updated with new TDTbin2mat.m

function TDT2NEX(BLOCKPATH)

    [pathstr,name,ext] = fileparts(BLOCKPATH);

    nexFilePath = strcat(BLOCKPATH, '\', name, '.nex');
    nex5FilePath = strcat(BLOCKPATH, '\', name, '.nex5');

    data = TDTbin2mat(BLOCKPATH, 'VERBOSE', 0);

    % start new nex file data
    nexFile = nexCreateFileData(24414.0625);

    % add streams
    fff = fields(data.streams);
    for i = 1:length(fff)
        m = data.streams.(fff{i});
        for j = 1:size(m.data,1)
            varname = strcat(m.name, '_', num2str(j));
            fprintf('adding %s\n', varname);
            nexFile = nexAddContinuous(nexFile, 1/m.fs, m.fs, m.data(j,:), varname);
        end
    end

    % add epocs
    fff = fields(data.epocs);
    for i = 1:length(fff)
        m = data.epocs.(fff{i});
        fprintf('adding %s\n', m.name);
        nexFile = nexAddEvent(nexFile, m.onset, m.name);
    end

    writeNexFile(nexFile, nexFilePath);
    fprintf('writing %s\n', nexFilePath);
    writeNex5File(nexFile, nex5FilePath);
    fprintf('writing %s\n', nex5FilePath);
    disp('done')
end