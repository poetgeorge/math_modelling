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
            if(j==2) %处理BMI数据
                if((D(i,j)<=24)&&(D(i,j)>=18))
                    M(j-1, cM) = 10;
                elseif(D(i,j)>24)
                    M(j-1, cM) = 10 - (D(i,j)-24);
                else
                    M(j-1, cM) = 10 - (18-D(i,j));
                end
            elseif(j==4)
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
            if(k==2) %处理BMI数据
                if((D(i,k)<=24)&&(D(i,k)>=18))
                    F(k-1, cF) = 10;
                elseif(D(i,k)>24)
                    F(k-1, cF) = 10 - (D(i,k)-24);
                else
                    F(k-1, cF) = 10 - (18-D(i,k));
                end
            elseif(k==4)
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
%计算最佳聚类数
% for i = 1:7
%     validXB(1:3) = [1 1 1];
%     X = M(i,:)';
%     for n = 4:20 %sqrt(size(X,1))
%         [cent, U, ob] = fcm(X,n);
%         validXB(n) = min(ob)/(size(X,1)*min(pdist(cent).^2));
%     end
%     [w(i),ncM(i)] = min(validXB);
%     validXB = [];
% end
% for i = 1:7
%     validXB(1:3) = [1 1 1];
%     X = F(i,:)';
%     for n = 4:20 %sqrt(size(X,1))
%         [cent, U, ob] = fcm(X,n);
%         validXB(n) = min(ob)/(size(X,1)*min(pdist(cent).^2));
%     end
%     [w(i),ncF(i)] = min(validXB);
%     validXB = [];
% end
%%
ncM = [4 11 7 7 6 7 9];
ncF = [5 12 11 11 8 11 8];
M = M';
F = F';

%%
UM = {zeros(ncM(1),cM), zeros(ncM(2),cM), zeros(ncM(3),cM), zeros(ncM(4),cM), zeros(ncM(5),cM), zeros(ncM(6),cM), zeros(ncM(7),cM)};
centreM = {zeros(1,ncM(1)), zeros(1,ncM(2)), zeros(1,ncM(3)), zeros(1,ncM(4)), zeros(1,ncM(5)), zeros(1,ncM(6)), zeros(1,ncM(7))};
indexM = {zeros(1,cM), zeros(1,cM), zeros(1,cM), zeros(1,cM), zeros(1,cM), zeros(1,cM), zeros(1,cM)};
for i = 1:7
    [centreM{i}, UM{i}] = fcm(M(:,i), ncM(i)); %模糊聚类
    for j = 1:cM
        [tmp,indexM{i}(j)] = max(UM{i}(:,j)); %确定每个点所属的类别
    end
    for j = 1:ncM(i) %确定最小标准区间，滤除了异常值的影响
        mea = mean(M(indexM{i}==j,i));
        st = std(M(indexM{i}==j,i));
        top = min(mea+3*st, max(M(indexM{i}==j,i)));
        bottom = max(mea-3*st, min(M(indexM{i}==j,i)));
        intv(j) = top - bottom;
    end
    interval = 0.5 * min(intv); 
    mea = mean(M(:,i));
    st = std(M(:,i));
    bottom = max(mea-3*st, min(M(:,i)));
    top = min(mea+3*st, max(M(:,i)));
    level = 70 * interval /(top-bottom);
    for j = 1:cM %打分，滤除了异常值的影响
        scoreM(j,i) = 30 + (M(j,i) - bottom)/interval * level; 
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
UF = {zeros(ncF(1),cF), zeros(ncF(2),cF), zeros(ncF(3),cF), zeros(ncF(4),cF), zeros(ncF(5),cF), zeros(ncF(6),cF), zeros(ncF(7),cF)};
centreF = {zeros(1,ncF(1)), zeros(1,ncF(2)), zeros(1,ncF(3)), zeros(1,ncF(4)), zeros(1,ncF(5)), zeros(1,ncF(6)), zeros(1,ncF(7))};
indexF = {zeros(1,cF), zeros(1,cF), zeros(1,cF), zeros(1,cF), zeros(1,cF), zeros(1,cF), zeros(1,cF)};
for i = 1:7
    [centreF{i}, UF{i}] = fcm(F(:,i), ncF(i)); %模糊聚类
    for j = 1:cF
        [tmp,indexF{i}(j)] = max(UF{i}(:,j));  %确定每个点所属的类别
    end
    for j = 1:ncF(i)  %确定最小标准区间，滤除了异常值的影响
        mea = mean(F(indexF{i}==j,i));
        st = std(F(indexF{i}==j,i));
        top = min(mea+3*st, max(F(indexF{i}==j,i)));
        bottom = max(mea-3*st, min(F(indexF{i}==j,i)));
        intv(j) = top - bottom;
    end
    interval = 0.5 * min(intv); 
    mea = mean(F(:,i));
    st = std(F(:,i));
    bottom = max(mea-3*st, min(F(:,i)));
    top = min(mea+3*st, max(F(:,i)));
    level = 70 * interval /(top-bottom);
    for j = 1:cF %打分，滤除了异常值的影响
        scoreF(j,i) = 30 + (F(j,i) - bottom)/interval * level; 
        scoreF(j,i) = ceil(scoreF(j,i));
        if(scoreF(j,i)>100)
            scoreF(j,i) = 100;
        elseif(scoreF(j,i)<0)
            scoreF(j,i) = 0;
        end
    end
end
