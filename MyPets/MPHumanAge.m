//
//  MPHumanAge.m
//  MyPets
//
//  Created by HP Developer on 13/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPHumanAge.h"

@implementation MPHumanAge

+ (id)shared
{
    static MPHumanAge *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MPHumanAge new];
        manager.arrayCanino = [NSMutableArray new];
        manager.arrayFelino = [NSMutableArray new];
        
        [manager loadCanino];
        [manager loadFelino];
    });
    
    return manager;
}


- (NSArray*)mes:(int)mes idade:(int)idade
{
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:mes],[NSNumber numberWithInt:idade], nil];
}

- (void)loadFelino
{
    /*Gato ----------- Homem
     1 ano ---------- 16 anos
     2 anos ---------- 24 anos
     3 anos ---------- 28 anos
     4 anos ---------- 32 anos
     8 anos ---------- 48 anos
     12 anos ---------- 64 anos
     15 anos ---------- 76 anos
     20 anos ----------- 96 anos*/
    
    [self.arrayFelino addObject:[self mes:0 idade:1]];
    [self.arrayFelino addObject:[self mes:1 idade:2]];
    [self.arrayFelino addObject:[self mes:2 idade:3]];
    [self.arrayFelino addObject:[self mes:3 idade:4]];
    [self.arrayFelino addObject:[self mes:3 idade:5]];
    [self.arrayFelino addObject:[self mes:4 idade:6]];
    [self.arrayFelino addObject:[self mes:5 idade:7]];
    [self.arrayFelino addObject:[self mes:6 idade:8]];
    [self.arrayFelino addObject:[self mes:6 idade:9]];
    [self.arrayFelino addObject:[self mes:7 idade:10]];
    [self.arrayFelino addObject:[self mes:8 idade:11]];
    [self.arrayFelino addObject:[self mes:9 idade:12]];
    [self.arrayFelino addObject:[self mes:9 idade:13]];
    [self.arrayFelino addObject:[self mes:10 idade:14]];
    [self.arrayFelino addObject:[self mes:11 idade:15]];
    [self.arrayFelino addObject:[self mes:12 idade:16]];
    [self.arrayFelino addObject:[self mes:17 idade:17]];
    [self.arrayFelino addObject:[self mes:18 idade:18]];
    [self.arrayFelino addObject:[self mes:19 idade:19]];
    [self.arrayFelino addObject:[self mes:20 idade:20]];
    [self.arrayFelino addObject:[self mes:21 idade:21]];
    [self.arrayFelino addObject:[self mes:22 idade:22]];
    [self.arrayFelino addObject:[self mes:23 idade:23]];
    [self.arrayFelino addObject:[self mes:24 idade:24]];
    [self.arrayFelino addObject:[self mes:32 idade:25]];
    [self.arrayFelino addObject:[self mes:33 idade:26]];
    [self.arrayFelino addObject:[self mes:34 idade:27]];
    [self.arrayFelino addObject:[self mes:36 idade:28]];
    [self.arrayFelino addObject:[self mes:43 idade:29]];
    [self.arrayFelino addObject:[self mes:45 idade:30]];
    [self.arrayFelino addObject:[self mes:46 idade:31]];
    [self.arrayFelino addObject:[self mes:48 idade:32]];
    [self.arrayFelino addObject:[self mes:66 idade:33]];
    [self.arrayFelino addObject:[self mes:68 idade:34]];
    [self.arrayFelino addObject:[self mes:70 idade:35]];
    [self.arrayFelino addObject:[self mes:72 idade:36]];
    [self.arrayFelino addObject:[self mes:74 idade:37]];
    [self.arrayFelino addObject:[self mes:76 idade:38]];
    [self.arrayFelino addObject:[self mes:78 idade:39]];
    [self.arrayFelino addObject:[self mes:80 idade:40]];
    [self.arrayFelino addObject:[self mes:82 idade:41]];
    [self.arrayFelino addObject:[self mes:84 idade:42]];
    [self.arrayFelino addObject:[self mes:86 idade:43]];
    [self.arrayFelino addObject:[self mes:88 idade:44]];
    [self.arrayFelino addObject:[self mes:90 idade:45]];
    [self.arrayFelino addObject:[self mes:92 idade:46]];
    [self.arrayFelino addObject:[self mes:94 idade:47]];
    [self.arrayFelino addObject:[self mes:96 idade:48]];
    [self.arrayFelino addObject:[self mes:110 idade:49]];
    [self.arrayFelino addObject:[self mes:112 idade:50]];
    [self.arrayFelino addObject:[self mes:114 idade:51]];
    [self.arrayFelino addObject:[self mes:117 idade:52]];
    [self.arrayFelino addObject:[self mes:119 idade:53]];
    [self.arrayFelino addObject:[self mes:121 idade:54]];
    [self.arrayFelino addObject:[self mes:123 idade:55]];
    [self.arrayFelino addObject:[self mes:126 idade:56]];
    [self.arrayFelino addObject:[self mes:128 idade:57]];
    [self.arrayFelino addObject:[self mes:130 idade:58]];
    [self.arrayFelino addObject:[self mes:132 idade:59]];
    [self.arrayFelino addObject:[self mes:135 idade:60]];
    [self.arrayFelino addObject:[self mes:137 idade:61]];
    [self.arrayFelino addObject:[self mes:139 idade:62]];
    [self.arrayFelino addObject:[self mes:141 idade:63]];
    [self.arrayFelino addObject:[self mes:144 idade:64]];
    [self.arrayFelino addObject:[self mes:153 idade:65]];
    [self.arrayFelino addObject:[self mes:156 idade:66]];
    [self.arrayFelino addObject:[self mes:158 idade:67]];
    [self.arrayFelino addObject:[self mes:161 idade:68]];
    [self.arrayFelino addObject:[self mes:163 idade:69]];
    [self.arrayFelino addObject:[self mes:165 idade:70]];
    [self.arrayFelino addObject:[self mes:168 idade:71]];
    [self.arrayFelino addObject:[self mes:170 idade:72]];
    [self.arrayFelino addObject:[self mes:172 idade:73]];
    [self.arrayFelino addObject:[self mes:175 idade:74]];
    [self.arrayFelino addObject:[self mes:177 idade:75]];
    [self.arrayFelino addObject:[self mes:180 idade:76]];
    [self.arrayFelino addObject:[self mes:192 idade:77]];
    [self.arrayFelino addObject:[self mes:195 idade:78]];
    [self.arrayFelino addObject:[self mes:197 idade:79]];
    [self.arrayFelino addObject:[self mes:200 idade:80]];
    [self.arrayFelino addObject:[self mes:202 idade:81]];
    [self.arrayFelino addObject:[self mes:205 idade:82]];
    [self.arrayFelino addObject:[self mes:207 idade:83]];
    [self.arrayFelino addObject:[self mes:210 idade:84]];
    [self.arrayFelino addObject:[self mes:212 idade:85]];
    [self.arrayFelino addObject:[self mes:215 idade:86]];
    [self.arrayFelino addObject:[self mes:217 idade:87]];
    [self.arrayFelino addObject:[self mes:220 idade:88]];
    [self.arrayFelino addObject:[self mes:222 idade:89]];
    [self.arrayFelino addObject:[self mes:225 idade:90]];
    [self.arrayFelino addObject:[self mes:227 idade:91]];
    [self.arrayFelino addObject:[self mes:230 idade:92]];
    [self.arrayFelino addObject:[self mes:232 idade:93]];
    [self.arrayFelino addObject:[self mes:235 idade:94]];
    [self.arrayFelino addObject:[self mes:237 idade:95]];
    [self.arrayFelino addObject:[self mes:240 idade:96]];
    
}

- (void)loadCanino
{
    [self.arrayCanino addObject:[self mes:0 idade:1]];
    [self.arrayCanino addObject:[self mes:1 idade:1]];
    [self.arrayCanino addObject:[self mes:3 idade:2]];
    [self.arrayCanino addObject:[self mes:5 idade:3]];
    [self.arrayCanino addObject:[self mes:6 idade:4]];
    [self.arrayCanino addObject:[self mes:8 idade:5]];
    [self.arrayCanino addObject:[self mes:10 idade:6]];
    [self.arrayCanino addObject:[self mes:12 idade:7]];
    [self.arrayCanino addObject:[self mes:13 idade:8]];
    [self.arrayCanino addObject:[self mes:15 idade:9]];
    [self.arrayCanino addObject:[self mes:17 idade:10]];
    [self.arrayCanino addObject:[self mes:18 idade:11]];
    [self.arrayCanino addObject:[self mes:20 idade:12]];
    [self.arrayCanino addObject:[self mes:22 idade:13]];
    [self.arrayCanino addObject:[self mes:24 idade:14]];
    [self.arrayCanino addObject:[self mes:25 idade:15]];
    [self.arrayCanino addObject:[self mes:27 idade:16]];
    [self.arrayCanino addObject:[self mes:29 idade:17]];
    [self.arrayCanino addObject:[self mes:30 idade:18]];
    [self.arrayCanino addObject:[self mes:32 idade:19]];
    [self.arrayCanino addObject:[self mes:34 idade:20]];
    [self.arrayCanino addObject:[self mes:36 idade:21]];
    [self.arrayCanino addObject:[self mes:37 idade:22]];
    [self.arrayCanino addObject:[self mes:39 idade:23]];
    [self.arrayCanino addObject:[self mes:41 idade:24]];
    [self.arrayCanino addObject:[self mes:42 idade:25]];
    [self.arrayCanino addObject:[self mes:44 idade:26]];
    [self.arrayCanino addObject:[self mes:46 idade:27]];
    [self.arrayCanino addObject:[self mes:48 idade:28]];
    [self.arrayCanino addObject:[self mes:49 idade:29]];
    [self.arrayCanino addObject:[self mes:51 idade:30]];
    [self.arrayCanino addObject:[self mes:53 idade:31]];
    [self.arrayCanino addObject:[self mes:54 idade:32]];
    [self.arrayCanino addObject:[self mes:56 idade:33]];
    [self.arrayCanino addObject:[self mes:58 idade:34]];
    [self.arrayCanino addObject:[self mes:60 idade:35]];
    [self.arrayCanino addObject:[self mes:61 idade:36]];
    [self.arrayCanino addObject:[self mes:63 idade:37]];
    [self.arrayCanino addObject:[self mes:65 idade:38]];
    [self.arrayCanino addObject:[self mes:66 idade:39]];
    [self.arrayCanino addObject:[self mes:68 idade:40]];
    [self.arrayCanino addObject:[self mes:70 idade:41]];
    [self.arrayCanino addObject:[self mes:72 idade:42]];
    [self.arrayCanino addObject:[self mes:73 idade:43]];
    [self.arrayCanino addObject:[self mes:75 idade:44]];
    [self.arrayCanino addObject:[self mes:77 idade:45]];
    [self.arrayCanino addObject:[self mes:78 idade:46]];
    [self.arrayCanino addObject:[self mes:80 idade:47]];
    [self.arrayCanino addObject:[self mes:82 idade:48]];
    [self.arrayCanino addObject:[self mes:84 idade:49]];
    [self.arrayCanino addObject:[self mes:85 idade:50]];
    [self.arrayCanino addObject:[self mes:87 idade:51]];
    [self.arrayCanino addObject:[self mes:89 idade:52]];
    [self.arrayCanino addObject:[self mes:90 idade:53]];
    [self.arrayCanino addObject:[self mes:92 idade:54]];
    [self.arrayCanino addObject:[self mes:94 idade:55]];
    [self.arrayCanino addObject:[self mes:96 idade:56]];
    [self.arrayCanino addObject:[self mes:97 idade:57]];
    [self.arrayCanino addObject:[self mes:99 idade:58]];
    [self.arrayCanino addObject:[self mes:101 idade:59]];
    [self.arrayCanino addObject:[self mes:102 idade:60]];
    [self.arrayCanino addObject:[self mes:104 idade:61]];
    [self.arrayCanino addObject:[self mes:106 idade:62]];
    [self.arrayCanino addObject:[self mes:108 idade:63]];
    [self.arrayCanino addObject:[self mes:109 idade:64]];
    [self.arrayCanino addObject:[self mes:111 idade:65]];
    [self.arrayCanino addObject:[self mes:113 idade:66]];
    [self.arrayCanino addObject:[self mes:114 idade:67]];
    [self.arrayCanino addObject:[self mes:116 idade:68]];
    [self.arrayCanino addObject:[self mes:118 idade:69]];
    [self.arrayCanino addObject:[self mes:120 idade:70]];
    [self.arrayCanino addObject:[self mes:121 idade:71]];
    [self.arrayCanino addObject:[self mes:123 idade:72]];
    [self.arrayCanino addObject:[self mes:125 idade:73]];
    [self.arrayCanino addObject:[self mes:126 idade:74]];
    [self.arrayCanino addObject:[self mes:128 idade:75]];
    [self.arrayCanino addObject:[self mes:130 idade:76]];
    [self.arrayCanino addObject:[self mes:132 idade:77]];
    [self.arrayCanino addObject:[self mes:133 idade:78]];
    [self.arrayCanino addObject:[self mes:135 idade:79]];
    [self.arrayCanino addObject:[self mes:137 idade:80]];
    [self.arrayCanino addObject:[self mes:138 idade:81]];
    [self.arrayCanino addObject:[self mes:140 idade:82]];
    [self.arrayCanino addObject:[self mes:142 idade:83]];
    [self.arrayCanino addObject:[self mes:144 idade:84]];
    [self.arrayCanino addObject:[self mes:145 idade:85]];
    [self.arrayCanino addObject:[self mes:147 idade:86]];
    [self.arrayCanino addObject:[self mes:149 idade:87]];
    [self.arrayCanino addObject:[self mes:150 idade:88]];
    [self.arrayCanino addObject:[self mes:152 idade:89]];
    [self.arrayCanino addObject:[self mes:154 idade:90]];
    [self.arrayCanino addObject:[self mes:156 idade:91]];
    [self.arrayCanino addObject:[self mes:157 idade:92]];
    [self.arrayCanino addObject:[self mes:159 idade:93]];
    [self.arrayCanino addObject:[self mes:161 idade:94]];
    [self.arrayCanino addObject:[self mes:162 idade:95]];
    [self.arrayCanino addObject:[self mes:164 idade:96]];
    [self.arrayCanino addObject:[self mes:166 idade:97]];
    [self.arrayCanino addObject:[self mes:168 idade:98]];
    [self.arrayCanino addObject:[self mes:169 idade:99]];
    [self.arrayCanino addObject:[self mes:171 idade:100]];
    [self.arrayCanino addObject:[self mes:173 idade:101]];
    [self.arrayCanino addObject:[self mes:174 idade:102]];
    [self.arrayCanino addObject:[self mes:176 idade:103]];
    [self.arrayCanino addObject:[self mes:178 idade:104]];
    [self.arrayCanino addObject:[self mes:180 idade:105]];
    [self.arrayCanino addObject:[self mes:181 idade:106]];
    [self.arrayCanino addObject:[self mes:183 idade:107]];
    [self.arrayCanino addObject:[self mes:185 idade:108]];
    [self.arrayCanino addObject:[self mes:186 idade:109]];
    [self.arrayCanino addObject:[self mes:188 idade:110]];
    [self.arrayCanino addObject:[self mes:190 idade:111]];
    [self.arrayCanino addObject:[self mes:192 idade:112]];
    [self.arrayCanino addObject:[self mes:193 idade:113]];
    [self.arrayCanino addObject:[self mes:195 idade:114]];
    [self.arrayCanino addObject:[self mes:197 idade:115]];
    [self.arrayCanino addObject:[self mes:198 idade:116]];
    [self.arrayCanino addObject:[self mes:200 idade:117]];
    [self.arrayCanino addObject:[self mes:202 idade:118]];
    [self.arrayCanino addObject:[self mes:204 idade:119]];
    [self.arrayCanino addObject:[self mes:205 idade:120]];
    [self.arrayCanino addObject:[self mes:207 idade:121]];
    [self.arrayCanino addObject:[self mes:209 idade:122]];
    [self.arrayCanino addObject:[self mes:210 idade:123]];
    [self.arrayCanino addObject:[self mes:212 idade:124]];
    [self.arrayCanino addObject:[self mes:214 idade:125]];
    [self.arrayCanino addObject:[self mes:216 idade:126]];
    [self.arrayCanino addObject:[self mes:217 idade:127]];
    [self.arrayCanino addObject:[self mes:219 idade:128]];
    [self.arrayCanino addObject:[self mes:221 idade:129]];
    [self.arrayCanino addObject:[self mes:222 idade:130]];
    [self.arrayCanino addObject:[self mes:224 idade:131]];
    [self.arrayCanino addObject:[self mes:226 idade:132]];
    [self.arrayCanino addObject:[self mes:228 idade:133]];
    [self.arrayCanino addObject:[self mes:229 idade:134]];
    [self.arrayCanino addObject:[self mes:231 idade:135]];
    [self.arrayCanino addObject:[self mes:233 idade:136]];
    [self.arrayCanino addObject:[self mes:234 idade:137]];
    [self.arrayCanino addObject:[self mes:236 idade:138]];
    [self.arrayCanino addObject:[self mes:238 idade:139]];
    [self.arrayCanino addObject:[self mes:240 idade:140]];
    [self.arrayCanino addObject:[self mes:241 idade:141]];
    [self.arrayCanino addObject:[self mes:243 idade:142]];
    [self.arrayCanino addObject:[self mes:245 idade:143]];
    [self.arrayCanino addObject:[self mes:246 idade:144]];
    [self.arrayCanino addObject:[self mes:248 idade:145]];
    [self.arrayCanino addObject:[self mes:250 idade:146]];
    [self.arrayCanino addObject:[self mes:252 idade:147]];
    [self.arrayCanino addObject:[self mes:253 idade:148]];
    [self.arrayCanino addObject:[self mes:255 idade:149]];
    [self.arrayCanino addObject:[self mes:257 idade:150]];
    [self.arrayCanino addObject:[self mes:258 idade:151]];
    [self.arrayCanino addObject:[self mes:260 idade:152]];
    [self.arrayCanino addObject:[self mes:262 idade:153]];
    [self.arrayCanino addObject:[self mes:264 idade:154]];
    [self.arrayCanino addObject:[self mes:265 idade:155]];
    [self.arrayCanino addObject:[self mes:267 idade:156]];
    [self.arrayCanino addObject:[self mes:269 idade:157]];
    [self.arrayCanino addObject:[self mes:270 idade:158]];
    [self.arrayCanino addObject:[self mes:272 idade:159]];
    [self.arrayCanino addObject:[self mes:274 idade:160]];
    [self.arrayCanino addObject:[self mes:276 idade:161]];
    [self.arrayCanino addObject:[self mes:277 idade:162]];
    [self.arrayCanino addObject:[self mes:279 idade:163]];
    [self.arrayCanino addObject:[self mes:281 idade:164]];
    [self.arrayCanino addObject:[self mes:282 idade:165]];
    [self.arrayCanino addObject:[self mes:284 idade:166]];
    [self.arrayCanino addObject:[self mes:286 idade:167]];
    [self.arrayCanino addObject:[self mes:288 idade:168]];
    [self.arrayCanino addObject:[self mes:289 idade:169]];
    [self.arrayCanino addObject:[self mes:291 idade:170]];
    [self.arrayCanino addObject:[self mes:293 idade:171]];
    [self.arrayCanino addObject:[self mes:294 idade:172]];
    [self.arrayCanino addObject:[self mes:296 idade:173]];
    [self.arrayCanino addObject:[self mes:298 idade:174]];
    [self.arrayCanino addObject:[self mes:300 idade:175]];
    [self.arrayCanino addObject:[self mes:301 idade:176]];
    [self.arrayCanino addObject:[self mes:303 idade:177]];
    [self.arrayCanino addObject:[self mes:305 idade:178]];
    [self.arrayCanino addObject:[self mes:306 idade:179]];
    [self.arrayCanino addObject:[self mes:308 idade:180]];
    [self.arrayCanino addObject:[self mes:310 idade:181]];
    [self.arrayCanino addObject:[self mes:312 idade:182]];
    [self.arrayCanino addObject:[self mes:313 idade:183]];
    [self.arrayCanino addObject:[self mes:315 idade:184]];
    [self.arrayCanino addObject:[self mes:317 idade:185]];
    [self.arrayCanino addObject:[self mes:318 idade:186]];
    [self.arrayCanino addObject:[self mes:320 idade:187]];
    [self.arrayCanino addObject:[self mes:322 idade:188]];
    [self.arrayCanino addObject:[self mes:324 idade:189]];
    [self.arrayCanino addObject:[self mes:325 idade:190]];
    [self.arrayCanino addObject:[self mes:327 idade:191]];
    [self.arrayCanino addObject:[self mes:329 idade:192]];
    [self.arrayCanino addObject:[self mes:330 idade:193]];
    [self.arrayCanino addObject:[self mes:332 idade:194]];
    [self.arrayCanino addObject:[self mes:334 idade:195]];
    [self.arrayCanino addObject:[self mes:336 idade:196]];
    [self.arrayCanino addObject:[self mes:337 idade:197]];
    [self.arrayCanino addObject:[self mes:339 idade:198]];
    [self.arrayCanino addObject:[self mes:341 idade:199]];
    [self.arrayCanino addObject:[self mes:342 idade:200]];
    
}

@end
