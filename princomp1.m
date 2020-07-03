%M男 F女
%对单年数据做主成分分析，然后进行模糊聚类
%%
clc;clear;
load('clean_data.mat');
Dt = cleandata(:, [3 7 8 9 10 11 12 13]);
D = table2array(Dt);
[length, count] = size(D);
cM = 0;
cF = 0;
for i = 1:length
    if(D(i, 1) == 1)
        cM = cM + 1;
        for j = 2:count
            if(j==4)
                M(j-1, cM) = 50.0/D(i, j);
            elseif(j==7)
                M(j-1, cM) = 400.0/D(i, j);  
            else
                M(j-1, cM) = D(i, j);
            end
        end
    else
        cF = cF + 1;
        for k = 2:count
            if(k==4)
                F(k-1, cF) = 50.0/D(i, k);
            elseif(k==7)
                F(k-1, cF) = 400.0/D(i, k);
            else
                F(k-1, cF) = D(i, k);
            end
        end
    end
end

%%
%数据标准化，减去均值后除以标准差，归到标准正态分布
Ms = zscore(M');
Fs = zscore(F');
% for i = 1:8
%     for j = 1:cM
%         tmp = max(M(i,:)) - min(M(i,:));
%         Ms(j,i) = (M(i,j) - min(M(i,:)))/tmp;
%     end
% end
% 
% for i = 1:8
%     for j = 1:cF
%         tmp = max(F(i,:)) - min(F(i,:));
%         Fs(j,i) = (F(i,j) - min(F(i,:)))/tmp;
%     end
% end

%%
%主成分分析
[pVecM, meanM, eigM, tsquaredM,explainedM,muM] = pca(Ms); 
[pVecF, meanF, eigF, tsquaredF,explainedF,muF] = pca(Fs);

Mnew = Ms * pVecM(:, [1 2 3 4]); %这里是按前四个主成分投影过后的数据，而且是标准化的
Fnew = Fs * pVecF(:, [1 2 3 4]);

%%
%这一节执行很慢，是计算最佳聚类数nc的
% for i =1:4
%     validXB(1:3) = [1000 1000 1000];
%     X = Mnew(:,i);
%     for n = 4:20 %sqrt(size(X,1))
%         [cent, U, ob] = fcm(X,n);
%         validXB(n) = min(ob)/(size(X,1)*min(pdist(cent).^2));
%     end
%     [w(i),ncM(i)] = min(validXB);
%     validXB = [];
% end

% for i =1:4
%     validXB(1:3) = [1000 1000 1000];
%     X = Fnew(:,i);
%     for n = 4:20 %sqrt(size(X,1))
%         [cent, UM, ob] = fcm(X,n);
%         validXB(n) = min(ob)/(size(X,1)*min(pdist(cent).^2));
%     end
%     [w(i),ncF(i)] = min(validXB);
%     validXB = [];
% end

%%
ncM = [10 8 8 8];
ncF = [5 10 9 11];

%%
UM = {zeros(ncM(1),cM), zeros(ncM(2),cM), zeros(ncM(3),cM), zeros(ncM(4),cM)};
centreM = {zeros(1,ncM(1)), zeros(1,ncM(2)), zeros(1,ncM(3)), zeros(1,ncM(4))};
indexM = {zeros(1,cM), zeros(1,cM), zeros(1,cM), zeros(1,cM)};
for i = 1:4
    [centreM{i}, UM{i}] = fcm(Mnew(:,i), ncM(i)); %模糊聚类
    for j = 1:cM
        [tmp,indexM{i}(j)] = max(UM{i}(:,j)); %确定每个点所属的类别
    end
    for j = 1:ncM(i) %打分
        top = min(3, max(Mnew(indexM{i}==j,i)));
        bottom = max(-3, min(Mnew(indexM{i}==j,i)));
        intv(j) = top - bottom;
    end
    interval = 0.5 * min(intv); 
    bottom = max(-3, min(Mnew(:,i)));
    top = min(3, max(Mnew(:,i)));
    level = 70 * interval /(top-bottom);
    for j = 1:cM
        scoreM(j,i) = 30 + (Mnew(j,i) - bottom)/interval * level; 
        scoreM(j,i) = ceil(scoreM(j,i));
        if(scoreM(j,i)>100)
            scoreM(j,i) = 100;
        elseif(scoreM(j,i)<0)
            scoreM(j,i) = 0;
        end
    end
end

%%
index = [];
UF = {zeros(ncF(1),cF), zeros(ncF(2),cF), zeros(ncF(3),cF), zeros(ncF(4),cF)};
centreF = {zeros(1,ncF(1)), zeros(1,ncF(2)), zeros(1,ncF(3)), zeros(1,ncF(4))};
indexF = {zeros(1,cF), zeros(1,cF), zeros(1,cF), zeros(1,cF)};
for i = 1:4
    [centreF{i}, UF{i}] = fcm(Fnew(:,i), ncF(i)); %模糊聚类
    for j = 1:cF
        [tmp,indexF{i}(j)] = max(UF{i}(:,j));  %确定每个点所属的类别
    end
    for j = 1:ncF(i) %打分
        top = min(3, max(Fnew(indexF{i}==j,i)));
        bottom = max(-3, min(Fnew(indexF{i}==j,i)));
        intv(j) = top - bottom;
    end
    interval = 0.5 * min(intv); 
    bottom = max(-3, min(Fnew(:,i)));
    top = min(3, max(Fnew(:,i)));
    level = 70 * interval /(top-bottom);
    for j = 1:cF
        scoreF(j,i) = 30 + (Fnew(j,i) - bottom)/interval * level; 
        scoreF(j,i) = ceil(scoreF(j,i));
        if(scoreF(j,i)>100)
            scoreF(j,i) = 100;
        elseif(scoreF(j,i)<0)
            scoreF(j,i) = 0;
        end
    end
end




    
        
