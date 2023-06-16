BULK INSERT INTO hits
(_id, watchid, javaenable, title, goodevent, eventtime, eventdate, counterid, clientip, regionid, userid, counterclass, os, useragent, url, referer, isrefresh, referercategoryid, refererregionid, urlcategoryid, urlregionid, resolutionwidth, resolutionheight, resolutiondepth, flashmajor, flashminor, flashminor2, netmajor, netminor, useragentmajor, useragentminor, cookieenable, javascriptenable, ismobile, mobilephone, mobilephonemodel, params, ipnetworkid, traficsourceid, searchengineid, searchphrase, advengineid, isartifical, windowclientwidth, windowclientheight, clienttimezone, clienteventtime, silverlightversion1, silverlightversion2, silverlightversion3, silverlightversion4, pagecharset, codeversion, islink, isdownload, isnotbounce, funiqid, originalurl, hid, isoldcounter, isevent, isparameter, dontcounthits, withhash, hitcolor, localeventtime, age, sex, income, interests, robotness, remoteip, windowname, openername, historylength, browserlanguage, browsercountry, socialnetwork, socialaction, httperror, sendtiming, dnstiming, connecttiming, responsestarttiming, responseendtiming, fetchtiming, socialsourcenetworkid, socialsourcepage, paramprice, paramorderid, paramcurrency, paramcurrencyid, openstatservicename, openstatcampaignid, openstatadid, openstatsourceid, utmsource, utmmedium, utmcampaign, utmcontent, utmterm, fromtag, hasgclid, refererhash, urlhash, clid)
map (
0 STRING,
1 INT,
2 STRING,
3 INT,
4 STRING,
5 STRING,
6 INT,
7 INT,
8 INT,
9 INT,
10 INT,
11 INT,
12 INT,
13 STRING,
14 STRING,
15 INT,
16 INT,
17 INT,
18 INT,
19 INT,
20 INT,
21 INT,
22 INT,
23 INT,
24 INT,
25 STRING,
26 INT,
27 INT,
28 INT,
29 STRING,
30 INT,
31 INT,
32 INT,
33 INT,
34 STRING,
35 STRING,
36 INT,
37 INT,
38 INT,
39 STRING,
40 INT,
41 INT,
42 INT,
43 INT,
44 INT,
45 STRING,
46 INT,
47 INT,
48 INT,
49 INT,
50 STRING,
51 INT,
52 INT,
53 INT,
54 INT,
55 STRING,
56 STRING,
57 INT,
58 INT,
59 INT,
60 INT,
61 INT,
62 INT,
63 STRING,
64 STRING,
65 INT,
66 INT,
67 INT,
68 INT,
69 INT,
70 INT,
71 INT,
72 INT,
73 INT,
74 STRING,
75 STRING,
76 STRING,
77 STRING,
78 INT,
79 INT,
80 INT,
81 INT,
82 INT,
83 INT,
84 INT,
85 INT,
86 STRING,
87 STRING,
88 STRING,
89 STRING,
90 INT,
91 STRING,
92 STRING,
93 STRING,
94 STRING,
95 STRING,
96 STRING,
97 STRING,
98 STRING,
99 STRING,
100 STRING,
101 INT,
102 INT,
103 INT,
104 INT
)
TRANSFORM (
CAST(@0 as STRING) || '-' || CAST(@8 as STRING) || '-' || CAST(@9 as STRING),
@0,
@1,
@2,
@3,
PARSETIMESTAMP(@4, '%Y-%m-%d %H:%M:%S'),
PARSETIMESTAMP(@5, '%Y-%m-%d'),
@6,
@7,
@8,
@9,
@10,
@11,
@12,
@13,
@14,
@15,
@16,
@17,
@18,
@19,
@20,
@21,
@22,
@23,
@24,
@25,
@26,
@27,
@28,
@29,
@30,
@31,
@32,
@33,
@34,
@35,
@36,
@37,
@38,
@39,
@40,
@41,
@42,
@43,
@44,
PARSETIMESTAMP(@45, '%Y-%m-%d %H:%M:%S'),
@46,
@47,
@48,
@49,
@50,
@51,
@52,
@53,
@54,
@55,
@56,
@57,
@58,
@59,
@60,
@61,
@62,
@63,
PARSETIMESTAMP(@64, '%Y-%m-%d %H:%M:%S'),
@65,
@66,
@67,
@68,
@69,
@70,
@71,
@72,
@73,
@74,
@75,
@76,
@77,
@78,
@79,
@80,
@81,
@82,
@83,
@84,
@85,
@86,
@87,
@88,
@89,
@90,
@91,
@92,
@93,
@94,
@95,
@96,
@97,
@98,
@99,
@100,
@101,
@102,
@103,
@104
)
from
'https://featurebase-public-data.s3.us-east-2.amazonaws.com/hits.csv'
with
    BATCHSIZE 100000
    format 'CSV'
    input 'URL';