function sumNPCs(matname, pathname)

% SUMNPCS(matname, pathname) 
% 
% This function populates the numNPCd_d6 field in all the data structures
% for each well in the file designated by matname. 
% 
% matname (string): name of the mat file
% pathname (string): path
%

load([pathname, matname]);
fieldnames = {'numTuj1_d6', 'numGFAP_d6', 'numDbl_d6', 'numUnst_d6'};

for i=1:4
    
    currWellName = [matname(1:end-4) '_w' num2str(i) '_data'];
    currWell = eval(currWellName);
    
    allvectors = cellfun(@(x) getfield(currWell, x), fieldnames, 'UniformOutput', false);
    allvectors = [allvectors{1:4}];
    
    reshapedMatrix = reshape(allvectors, 247,4)';
    totalNPCs = sum(reshapedMatrix,1);
    eval([currWellName '.numNPCs_d6 = totalNPCs;']);
    
    save([pathname, matname], currWellName, '-append');

end


    
    