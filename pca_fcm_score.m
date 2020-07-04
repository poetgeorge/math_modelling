function [pcaF, pcaM, fcmF, fcmM, scoreF, scoreM] = pca_fcm_score(M, F)
%对输入数据进行主成分分析，将数据在第一主成分上投影，然后进行模糊聚类，进而打分
%M：男生数据 F：女生数据 一行代表一人，一列代表一个指标
%pcaM：主成分分析结果 依次是特征向量pVecM, 旋转后矩阵srM, 特征值eigM，看不懂的tsquaredM，信息量百分数explainedM，元数据均值估计muM
%fcmM：模糊聚类结果 依次是（标准化后的）聚类中心centreM，隶属度函数UM，每点所属类别indexM
%scoreM：每个人的得分

%数据标准化
Ms = zscore(M);
Fs = zscore(F);

%主成分分析
[pVecM, srM, eigM, tsquaredM,explainedM,muM] = pca(Ms); 
[pVecF, srF, eigF, tsquaredF,explainedF,muF] = pca(Fs);
Mnew = Ms * pVecM(:, 1); %这里是按第一主成分投影过后的数据
Fnew = Fs * pVecF(:, 1);
pcaF = {pVecF, srF, eigF, tsquaredF,explainedF,muF};
pcaM = {pVecM, srM, eigM, tsquaredM,explainedM,muM};


%这一节执行很慢，是计算最佳聚类数nc的
validXB(1:3) = [1000 1000 1000];
X = Mnew(:,1);
for n = 4:20 %sqrt(size(X,1))
    [cent, U, ob] = fcm(X,n);
    validXB(n) = min(ob)/(size(X,1)*min(pdist(cent).^2));
end
[w,ncM] = min(validXB);
validXB = [];

validXB(1:3) = [1000 1000 1000];
X = Fnew(:,1);
for n = 4:20 %sqrt(size(X,1))
    [cent, U, ob] = fcm(X,n);
    validXB(n) = min(ob)/(size(X,1)*min(pdist(cent).^2));
end
[w,ncF] = min(validXB);
validXB = [];


%ncM = [10 8 8 8];
%ncF = [5 10 9 11];

% UM = {zeros(ncM(1),cM), zeros(ncM(2),cM), zeros(ncM(3),cM), zeros(ncM(4),cM)};
% centreM = {zeros(1,ncM(1)), zeros(1,ncM(2)), zeros(1,ncM(3)), zeros(1,ncM(4))};
% indexM = {zeros(1,cM), zeros(1,cM), zeros(1,cM), zeros(1,cM)};

cM = size(Mnew, 1);
cF = size(Fnew, 1);
[centreM, UM] = fcm(Mnew(:,1), ncM); %模糊聚类
for j = 1:cM
    [tmp,indexM(j)] = max(UM(:,j)); %确定每个点所属的类别
end
for j = 1:ncM %打分
    top = min(3, max(Mnew(indexM==j,1)));
    bottom = max(-3, min(Mnew(indexM==j,1)));
    intv(j) = top - bottom;
end
interval = 0.5 * min(intv); 
bottom = max(-3, min(Mnew(:,1)));
top = min(3, max(Mnew(:,1)));
level = 70 * interval /(top-bottom);
for j = 1:cM
    scoreM(j) = 30 + (Mnew(j,1) - bottom)/interval * level; 
    scoreM(j) = ceil(scoreM(j));
    if(scoreM(j)>100)
        scoreM(j) = 100;
    elseif(scoreM(j)<0)
        scoreM(j) = 0;
    end
end
fcmM = {centreM, UM, indexM};

intv = [];
% UF = {zeros(ncF(1),cF), zeros(ncF(2),cF), zeros(ncF(3),cF), zeros(ncF(4),cF)};
% centreF = {zeros(1,ncF(1)), zeros(1,ncF(2)), zeros(1,ncF(3)), zeros(1,ncF(4))};
% indexF = {zeros(1,cF), zeros(1,cF), zeros(1,cF), zeros(1,cF)};
[centreF, UF] = fcm(Fnew(:,1), ncF); %模糊聚类
for j = 1:cF
    [tmp,indexF(j)] = max(UF(:,j));  %确定每个点所属的类别
end
for j = 1:ncF %打分
    top = min(3, max(Fnew(indexF==j,1)));
    bottom = max(-3, min(Fnew(indexF==j,1)));
    intv(j) = top - bottom;
end
interval = 0.5 * min(intv); 
bottom = max(-3, min(Fnew(:,1)));
top = min(3, max(Fnew(:,1)));
level = 70 * interval /(top-bottom);
for j = 1:cF
    scoreF(j) = 30 + (Fnew(j,1) - bottom)/interval * level; 
    scoreF(j) = ceil(scoreF(j));
    if(scoreF(j)>100)
        scoreF(j) = 100;
    elseif(scoreF(j)<0)
        scoreF(j) = 0;
    end
end
fcmF = {centreF, UF, indexF};

end