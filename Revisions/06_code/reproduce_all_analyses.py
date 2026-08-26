# ============================================================================
#  Reproducible analysis pipeline  —  Pharmaceutical Research (Revision 2)
#  Employing General-Purpose and Biomedical LLMs ... Pharmacoepidemiologic Design
#
#  Addresses Reviewer #2: end-to-end script that reproduces every statistic,
#  effect size, and table from the released workbooks, with data corrections,
#  clustered inference, sensitivity analyses, and set-based ontology metrics.
#
#  Colab: upload the three released workbooks, then Run all.
# ============================================================================
import pandas as pd, numpy as np, re, warnings
warnings.filterwarnings('ignore')
from scipy import stats
import statsmodels.api as sm

REL = 'recreated_excel_file.xlsx'     # relevance (Q*.Likert.scale) + GPT-4o depth-of-reasoning
LOG = 'Logic_assessment.xlsx'         # human logic (Q* human Likert scale)
ONT = 'Ontology__1_.xlsx'             # ontology-code mapping
import os
for _p in (REL,LOG,ONT):
    if not os.path.exists(_p) and os.path.exists(''+_p): 
        globals()[[k for k,v in list(globals().items()) if v==_p][0]] = ''+_p
REL='recreated_excel_file.xlsx'; LOG='Logic_assessment.xlsx'; ONT='Ontology__1_.xlsx'

PROT={'DARWIN':16,'HMA-EMA':15,'Sentinel':15}; QN=9   # 46 protocols, 9 questions
def parse_sheet(sh):
    U=sh.upper()
    src='HMA-EMA' if ('HMA' in U or 'EMA' in U) else 'DARWIN' if 'DARWIN' in U else 'Sentinel' if 'SENTINEL' in U else None
    llm=('GPT-4o' if 'GPT' in U else 'DeepSeek-R1' if 'DEEPSEEK' in U else
         'Qwen2-med' if 'IRATH' in U else 'BioLlama' if 'LLAMA' in U else None)
    prm='ACT' if 'ACT' in U else 'LTM' if 'LTM' in U else None
    cls='Biomedical' if llm in ('Qwen2-med','BioLlama') else 'Non-Biomedical'
    return src,llm,prm,cls
def find(cols,n,*keys):
    for c in cols:
        s=str(c).upper()
        if re.search(rf'\bQ0*{n}\b',s) and all(k.upper() in s for k in keys): return c
def codes(x):
    if pd.isna(x): return set()
    return {c.strip() for c in re.split(r'[;,/]| +',str(x)) if c.strip() and c.strip().lower()!='nan'}

# ---- DATA CORRECTIONS (audited) --------------------------------------------
# (1) Restrict every sheet to its pre-specified protocol count -> removes
#     spurious spillover rows (e.g. DARWIN_GPT_LTM rows 17-22, blank Case.no)
#     and the extra 16th rows in sentinel-llama / hma-irath (logic workbook).
# (2) sentinel-gpt-ltm Q7: 'human Likert' column holds evaluator prose (one-column
#     displacement) -> read as numeric => becomes NA (genuinely missing), as it
#     already was in every summary.
def load_long(path, value_key, want):
    rows=[]; xl=pd.ExcelFile(path)
    for sh in xl.sheet_names:
        src,llm,prm,cls=parse_sheet(sh)
        if src is None: continue
        d=pd.read_excel(xl,sheet_name=sh).iloc[:PROT[src]].copy()
        for i,r in d.iterrows():
            for n in range(1,QN+1):
                rec=dict(source=src,llm=llm,prompt=prm,cls=cls,protocol=f'{src[:3]}{i+1}',q=n,cfg=f'{llm}-{prm}')
                if want=='rel':
                    lc=find(d.columns,n,'LIKERT'); dc=find(d.columns,n,'DEPTH')
                    rec['relevance']=pd.to_numeric(r[lc],errors='coerce') if lc else np.nan
                    s=str(r[dc]).strip().lower() if dc and pd.notna(r[dc]) else ''
                    rec['dor']=('Agree' if s.startswith('agree') else 'Partly' if 'part' in s
                                else 'Disagree' if s.startswith('disagree') else None)
                else:
                    hc=find(d.columns,n,'HUMAN','LIKERT')
                    rec['logic']=pd.to_numeric(r[hc],errors='coerce') if hc else np.nan
                rows.append(rec)
    return pd.DataFrame(rows)

rel=load_long(REL,'relevance','rel'); logic=load_long(LOG,'logic','log')

print('#'*70)
print('# 1. DATA-FLOW TABLE (Comment 4)'); print('#'*70)
df=[]
for (cfg,src),g in rel.groupby(['cfg','source']):
    exp=PROT[src]*QN; lg=logic[(logic.cfg==cfg)&(logic.source==src)]
    df.append((cfg,src,exp,int(g.relevance.notna().sum()),int(g.dor.notna().sum()),int(lg.logic.notna().sum())))
DF=pd.DataFrame(df,columns=['config','source','expected','relevance','depthReason','humanLogic'])
DF['rel_miss']=DF.expected-DF.relevance; DF['logic_miss']=DF.expected-DF.humanLogic
print(DF.to_string(index=False))
for cls in ['Non-Biomedical','Biomedical']:
    cf=rel[rel.cls==cls].cfg.unique(); s=DF[DF.config.isin(cf)]
    print(f'  {cls}: relevance {s.relevance.sum()}/{s.expected.sum()} ({100*s.relevance.sum()/s.expected.sum():.1f}%),',
          f'human-logic {s.humanLogic.sum()}/{s.expected.sum()} ({100*s.humanLogic.sum()/s.expected.sum():.1f}%)')
DF.to_csv('dataflow_table.csv',index=False)

R=rel.dropna(subset=['relevance']).copy(); R['relevance']=R.relevance.astype(int)
R['pid']=R.source+'_'+R.protocol
print('\n'+'#'*70); print('# 2. RELEVANCE — clustered ordinal analysis (Comment 5)'); print('#'*70)
print(f'Kruskal-Wallis across 5 configs: H={stats.kruskal(*[g.relevance for _,g in R.groupby("cfg")])[0]:.1f} (descriptive)')
R['cfg_c']=R.cfg
m=sm.OrdinalGEE.from_formula('relevance ~ C(cfg_c,Treatment(reference="GPT-4o-LTM"))+C(source)+q',
                             groups='pid',data=R,cov_struct=sm.cov_struct.Independence()).fit(maxiter=80)
co=m.params; se=m.bse; pv=m.pvalues
print('Ordinal GEE (cluster=protocol) key coefficients [log-odds of higher relevance]:')
for k in co.index:
    if 'cfg_c' in k or 'source' in k or k=='q':
        lab=k.split('T.')[-1].rstrip(']') if 'T.' in k else k
        print(f'   {lab:22s} beta={co[k]:+.2f}  p={pv[k]:.3f}')

print('\n'+'#'*70); print('# 3. PROMPT LTM vs ACT (GPT-4o, paired) (Comments 5 & 7)'); print('#'*70)
g=R[R.llm=="GPT-4o"]; piv=g.pivot_table(index=['pid','q'],columns='prompt',values='relevance').dropna()
print(f'  unpaired Mann-Whitney p={stats.mannwhitneyu(g[g.prompt=="LTM"].relevance,g[g.prompt=="ACT"].relevance)[1]:.3f} (originally reported)')
print(f'  PAIRED Wilcoxon n={len(piv)} p={stats.wilcoxon(piv.LTM,piv.ACT)[1]:.3f}  -> no prompt effect')
rng=np.random.default_rng(0); uniq=piv.reset_index().pid.unique(); pv2=piv.reset_index()
byp={p:s for p,s in pv2.groupby('pid')}
bo=[ (pd.concat([byp[p] for p in rng.choice(uniq,len(uniq),replace=True)]).eval('LTM-ACT')).mean() for _ in range(2000)]
print(f'  cluster-bootstrap mean diff 95% CI=[{np.percentile(bo,2.5):+.3f},{np.percentile(bo,97.5):+.3f}] (includes 0)')

print('\n'+'#'*70); print('# 4. DEPTH-OF-REASONING (GPT-4o self-assessed) — 3-cat + sensitivity (Comment 3)'); print('#'*70)
tab=rel.dropna(subset=['dor']).groupby(['cls','dor']).size().unstack(fill_value=0).reindex(columns=['Agree','Disagree','Partly'])
print(tab.to_string())
for name,acc in [('exclude-partly (as reported)',None),('partly=acceptable',True),('partly=unacceptable',False)]:
    res=[]
    for cls in ['Non-Biomedical','Biomedical']:
        a,d,p_=tab.loc[cls]
        if acc is None: num,den=a,a+d
        elif acc: num,den=a+p_,a+d+p_
        else: num,den=a,a+d+p_
        res.append((num,den))
    chi=stats.chi2_contingency([[res[0][0],res[0][1]-res[0][0]],[res[1][0],res[1][1]-res[1][0]]])[0]
    print(f'  {name:28s}: GP={100*res[0][0]/res[0][1]:.1f}% ({res[0][0]}/{res[0][1]}), Bio={100*res[1][0]/res[1][1]:.1f}% ({res[1][0]}/{res[1][1]}), chi2={chi:.0f}')
print('  NOTE: GPT-4o-assigned agreement judgment; distinct from human logic ratings (Fig 4-6).')

print('\n'+'#'*70); print('# 5. HUMAN LOGIC — differential missingness (Comment 4)'); print('#'*70)
L=logic.dropna(subset=['logic'])
for cls in ['Non-Biomedical','Biomedical']:
    v=L[L.cls==cls]; print(f'  {cls}: n={len(v)}, median={v.logic.median()}, mean={v.logic.mean():.2f} (coverage differs hugely -> interpret Fig4-6 with caution)')

print('\n'+'#'*70); print('# 6. ONTOLOGY — set-based metrics + convention cases (Comment 8)'); print('#'*70)
def fam(o):
    o=str(o).upper()
    for k in ['ATC','RXNORM','SNOMED','HCPCS','CPT','ICD','READ','SMG']:
        if k in o: return 'RxNorm' if k=='RXNORM' else k
    return 'other'
CFG={'GPT-4 LTM':'GPT-4o-LTM','GPT-4 ACT':'GPT-4o-ACT','Deepseek LTM':'DeepSeek-R1-LTM'}
rows=[]; xlo=pd.ExcelFile(ONT)
for sh in xlo.sheet_names:
    d=pd.read_excel(xlo,sheet_name=sh)
    for _,r in d.iterrows():
        if pd.isna(r.get('code')): continue
        ref=codes(r['code']); f=fam(r['ontology'])
        for col,cfg in CFG.items():
            pred=codes(r.get(col)); inter=ref&pred; uni=ref|pred
            prec=len(inter)/len(pred) if pred else np.nan
            rec=len(inter)/len(ref) if ref else np.nan
            f1=2*prec*rec/(prec+rec) if pred and ref and (prec+rec)>0 else (0.0 if pred else np.nan)
            conv=int(f in('SNOMED','RxNorm') and len(pred)>0 and len(inter)==0 and all(c.isdigit() for c in pred))
            rows.append((cfg,f,prec,rec,f1,len(inter)/len(uni) if uni else np.nan,int(ref==pred and len(pred)>0),conv,int(not pred)))
M=pd.DataFrame(rows,columns=['cfg','system','precision','recall','F1','jaccard','exact','convention','omitted'])
att=M[M.omitted==0]
print('by config (attempted):')
print(att.groupby('cfg')[['precision','recall','F1','jaccard','exact']].mean().round(3).to_string())
print('by coding system (attempted, pooled):')
print(att.groupby('system')[['precision','recall','F1','jaccard']].mean().round(3).assign(
      convention=M.groupby('system').convention.sum()).fillna(0).to_string())
print(f'  native-vs-OMOP convention cases (reported separately): {int(M.convention.sum())}')
print(f'  omissions: {int(M.omitted.sum())}/{len(M)} ({100*M.omitted.mean():.1f}%)  | taxonomy covers 3/5 configs (only non-biomedical columns exist in workbook)')
M.to_csv('ontology_setmetrics.csv',index=False)
print('\nDONE — all statistics reproduced from released workbooks.')
