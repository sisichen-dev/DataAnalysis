function [filteredData outlierData] = filterOutliers(dataFrame, CortANames)

% FILTEROUTLIERS returns a dataFrame that has the outliers removed
% 
% [filteredData outlierData] = filterOutlier(dataFrame, CortANames)
%
% There are three criteria for outliers: 
%
% 1. Tuj1+ field at day 6 = 99 (user says pattern is unquantifiable).
% 2. the pattern has NPCs at day 0, but no NPCs at day 6
% 3. the pattern has CortA (of any kind) at day 0, but no CortA at day 6
% 4. the pattern has no NPCs at day 0 but NPCs at day 6 
% 5. the pattern has no CortA (of any kind) at day 0, but CortA at day 6 
%
% dataFrame (struct): input data structure (i.e. sl21_w1_data);
% CortANames (cell array): specifies names of CortA in experiment. Usually 
%            one, but possibly two types of CortA
% filteredData (struct): same fields, just with outliers removed
% outlierData (struct): add these fields: 
%  outlier_unQuant_Ind: indices of patterns with 99 in numTuj1_d6
%  outlier_unQuant_num:  
%  outlier_unQuant_perc: 
%  outlier_NPCLoss_Ind: indices of patterns that lose NPCs by d6
%  outlier_NPCLoss_num: 
%  outlier_NPCLoss_perc:
%  outlier_CortALoss_Ind: indices of patterns that lose all CortA by d6
%  outlier_CortALoss_num: 
%  outlier_CortALoss_perc: 
%  outlier_NPCGain_Ind: indices of patterns that gain NPCs by d6(0 at d0)
%  outlier_NPCGain_num:     
%  outlier_NPCGain_perc:
%  outlier_CortAGain_Ind: indices of patterns gain CortA by d6(0 at d0)
%  outlier_CortAGain_num:
%  outlier_CortAGain_perc: 


totalnum = length(dataFrame.numTuj1_d6);

%% Criteria 1: user says the pattern is unquantifiable
unQuantIndices = find(dataFrame.numTuj1_d6==99);
outlierData.outlier_unQuant_Ind = find(dataFrame.numTuj1_d6==99);
outlierData.outlier_unQuant_num = length(outlierData.outlier_unQuant_Ind);
outlierData.outlier_unQuant_perc = outlierData.outlier_unQuant_num/totalnum;


%% Criteria 2: no NPCs at day 6 -> NPC loss

d0NPCs = find(dataFrame.numNPCs_d0>0);
d6ZeroNPCs = find(dataFrame.numNPCs_d6==0);
NPCLossIndices = intersect(d0NPCs,d6ZeroNPCs);

outlierData.outlier_NPCLoss_Ind = setdiff(NPCLossIndices, unQuantIndices); % remove all the cases in which Criteria 1 was already applied
outlierData.outlier_NPCLoss_num = length(outlierData.outlier_NPCLoss_Ind);
outlierData.outlier_NPCLoss_perc = outlierData.outlier_NPCLoss_num/totalnum;


%% Criteria 3: no CortA at day 6 -> CortA loss 

CortALossIndices=[];

for i=CortANames
    
    currd0CortA = eval(['find(dataFrame.num' i{1} '_d0>0)']);
    currd6ZeroCortAs = eval(['find(dataFrame.num' i{1} '_d6==0)']);
    
    currCortALossIndices = intersect(currd0CortA,currd6ZeroCortAs);
    CortALossIndices = [CortALossIndices,currCortALossIndices];
    
end

outlierData.outlier_CortALoss_Ind = setdiff(CortALossIndices, unQuantIndices); % remove all the cases in which Criteria 1 was already applied
outlierData.outlier_CortALoss_num = length(outlierData.outlier_CortALoss_Ind);
outlierData.outlier_CortALoss_perc = outlierData.outlier_CortALoss_num/totalnum;


%% Criteria 4: no NPCs at day 0 but NPCs at day 6

d0ZeroNPCs = find(dataFrame.numNPCs_d0==0);
d6NPCs = find(dataFrame.numNPCs_d6>0);
NPCGainIndices = intersect(d0ZeroNPCs,d6NPCs);

outlierData.outlier_NPCGain_Ind = setdiff(NPCGainIndices, unQuantIndices); % remove all the cases in which Criteria 1 was already applied
outlierData.outlier_NPCGain_num = length(outlierData.outlier_NPCGain_Ind);
outlierData.outlier_NPCGain_perc = outlierData.outlier_NPCGain_num/totalnum;


%% Criteria 3: no CortA at day 0, but CortA at day 6 -> CortA gain 

CortAGainIndices=[];

for i=CortANames
    
    currd0ZeroCortA = eval(['find(dataFrame.num' i{1} '_d0==0)']);
    currd6CortAs = eval(['find(dataFrame.num' i{1} '_d6>0)']);
    
    currCortAGainIndices = intersect(currd0ZeroCortA,currd6CortAs);
    CortAGainIndices = [CortAGainIndices,currCortAGainIndices];
    
end

outlierData.outlier_CortAGain_Ind = setdiff(CortAGainIndices, unQuantIndices); % remove all the cases in which Criteria 1 was already applied
outlierData.outlier_CortAGain_num = length(outlierData.outlier_CortAGain_Ind);
outlierData.outlier_CortAGain_perc = outlierData.outlier_CortAGain_num/totalnum;


%% Combine all indices together

filterOutIndices = unique([unQuantIndices, NPCLossIndices, CortALossIndices, NPCGainIndices, CortAGainIndices]);

% remove all data with these indices

names = fieldnames(dataFrame);

for i = 1:length(names)
    
    currVector = eval(['dataFrame.' names{i}]);
    
    if any(currVector) && (max(filterOutIndices)<=totalnum) % requires currVector to at least have some nonzero values (i.e. not just 0's concatenated) 
    
        currVector(filterOutIndices)=[]; % remove all elements at these indices
        eval(['dataFrame.' names{i} ' = currVector']);

    end
    
end

filteredData = dataFrame;

    

