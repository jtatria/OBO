
/* First created by JCasGen Mon Jun 18 18:20:05 CLT 2018 */
package edu.columbia.incite.uima.api.types.obo;

import org.apache.uima.jcas.JCas;
import org.apache.uima.jcas.JCasRegistry;
import org.apache.uima.cas.impl.CASImpl;
import org.apache.uima.cas.impl.FSGenerator;
import org.apache.uima.cas.FeatureStructure;
import org.apache.uima.cas.impl.TypeImpl;
import org.apache.uima.cas.Type;
import org.apache.uima.cas.impl.FeatureImpl;
import org.apache.uima.cas.Feature;

/** Session metadata
 * Updated by JCasGen Mon Jun 18 18:20:05 CLT 2018
 * @generated */
public class Session_Type extends OBOSegment_Type {
  /** @generated 
   * @return the generator for this type
   */
  @Override
  protected FSGenerator getFSGenerator() {return fsGenerator;}
  /** @generated */
  private final FSGenerator fsGenerator = 
    new FSGenerator() {
      public FeatureStructure createFS(int addr, CASImpl cas) {
  			 if (Session_Type.this.useExistingInstance) {
  			   // Return eq fs instance if already created
  		     FeatureStructure fs = Session_Type.this.jcas.getJfsFromCaddr(addr);
  		     if (null == fs) {
  		       fs = new Session(addr, Session_Type.this);
  			   Session_Type.this.jcas.putJfsFromCaddr(addr, fs);
  			   return fs;
  		     }
  		     return fs;
        } else return new Session(addr, Session_Type.this);
  	  }
    };
  /** @generated */
  @SuppressWarnings ("hiding")
  public final static int typeIndexID = Session.typeIndexID;
  /** @generated 
     @modifiable */
  @SuppressWarnings ("hiding")
  public final static boolean featOkTst = JCasRegistry.getFeatOkTst("edu.columbia.incite.uima.api.types.obo.Session");
 
  /** @generated */
  final Feature casFeat_proc_dupes;
  /** @generated */
  final int     casFeatCode_proc_dupes;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public int getProc_dupes(int addr) {
        if (featOkTst && casFeat_proc_dupes == null)
      jcas.throwFeatMissing("proc_dupes", "edu.columbia.incite.uima.api.types.obo.Session");
    return ll_cas.ll_getRefValue(addr, casFeatCode_proc_dupes);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setProc_dupes(int addr, int v) {
        if (featOkTst && casFeat_proc_dupes == null)
      jcas.throwFeatMissing("proc_dupes", "edu.columbia.incite.uima.api.types.obo.Session");
    ll_cas.ll_setRefValue(addr, casFeatCode_proc_dupes, v);}
    
   /** @generated
   * @param addr low level Feature Structure reference
   * @param i index of item in the array
   * @return value at index i in the array 
   */
  public String getProc_dupes(int addr, int i) {
        if (featOkTst && casFeat_proc_dupes == null)
      jcas.throwFeatMissing("proc_dupes", "edu.columbia.incite.uima.api.types.obo.Session");
    if (lowLevelTypeChecks)
      return ll_cas.ll_getStringArrayValue(ll_cas.ll_getRefValue(addr, casFeatCode_proc_dupes), i, true);
    jcas.checkArrayBounds(ll_cas.ll_getRefValue(addr, casFeatCode_proc_dupes), i);
	return ll_cas.ll_getStringArrayValue(ll_cas.ll_getRefValue(addr, casFeatCode_proc_dupes), i);
  }
   
  /** @generated
   * @param addr low level Feature Structure reference
   * @param i index of item in the array
   * @param v value to set
   */ 
  public void setProc_dupes(int addr, int i, String v) {
        if (featOkTst && casFeat_proc_dupes == null)
      jcas.throwFeatMissing("proc_dupes", "edu.columbia.incite.uima.api.types.obo.Session");
    if (lowLevelTypeChecks)
      ll_cas.ll_setStringArrayValue(ll_cas.ll_getRefValue(addr, casFeatCode_proc_dupes), i, v, true);
    jcas.checkArrayBounds(ll_cas.ll_getRefValue(addr, casFeatCode_proc_dupes), i);
    ll_cas.ll_setStringArrayValue(ll_cas.ll_getRefValue(addr, casFeatCode_proc_dupes), i, v);
  }
 
 
  /** @generated */
  final Feature casFeat_proc_does;
  /** @generated */
  final int     casFeatCode_proc_does;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public int getProc_does(int addr) {
        if (featOkTst && casFeat_proc_does == null)
      jcas.throwFeatMissing("proc_does", "edu.columbia.incite.uima.api.types.obo.Session");
    return ll_cas.ll_getRefValue(addr, casFeatCode_proc_does);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setProc_does(int addr, int v) {
        if (featOkTst && casFeat_proc_does == null)
      jcas.throwFeatMissing("proc_does", "edu.columbia.incite.uima.api.types.obo.Session");
    ll_cas.ll_setRefValue(addr, casFeatCode_proc_does, v);}
    
   /** @generated
   * @param addr low level Feature Structure reference
   * @param i index of item in the array
   * @return value at index i in the array 
   */
  public String getProc_does(int addr, int i) {
        if (featOkTst && casFeat_proc_does == null)
      jcas.throwFeatMissing("proc_does", "edu.columbia.incite.uima.api.types.obo.Session");
    if (lowLevelTypeChecks)
      return ll_cas.ll_getStringArrayValue(ll_cas.ll_getRefValue(addr, casFeatCode_proc_does), i, true);
    jcas.checkArrayBounds(ll_cas.ll_getRefValue(addr, casFeatCode_proc_does), i);
	return ll_cas.ll_getStringArrayValue(ll_cas.ll_getRefValue(addr, casFeatCode_proc_does), i);
  }
   
  /** @generated
   * @param addr low level Feature Structure reference
   * @param i index of item in the array
   * @param v value to set
   */ 
  public void setProc_does(int addr, int i, String v) {
        if (featOkTst && casFeat_proc_does == null)
      jcas.throwFeatMissing("proc_does", "edu.columbia.incite.uima.api.types.obo.Session");
    if (lowLevelTypeChecks)
      ll_cas.ll_setStringArrayValue(ll_cas.ll_getRefValue(addr, casFeatCode_proc_does), i, v, true);
    jcas.checkArrayBounds(ll_cas.ll_getRefValue(addr, casFeatCode_proc_does), i);
    ll_cas.ll_setStringArrayValue(ll_cas.ll_getRefValue(addr, casFeatCode_proc_does), i, v);
  }
 
 
  /** @generated */
  final Feature casFeat_proc_dirs;
  /** @generated */
  final int     casFeatCode_proc_dirs;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public int getProc_dirs(int addr) {
        if (featOkTst && casFeat_proc_dirs == null)
      jcas.throwFeatMissing("proc_dirs", "edu.columbia.incite.uima.api.types.obo.Session");
    return ll_cas.ll_getRefValue(addr, casFeatCode_proc_dirs);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setProc_dirs(int addr, int v) {
        if (featOkTst && casFeat_proc_dirs == null)
      jcas.throwFeatMissing("proc_dirs", "edu.columbia.incite.uima.api.types.obo.Session");
    ll_cas.ll_setRefValue(addr, casFeatCode_proc_dirs, v);}
    
   /** @generated
   * @param addr low level Feature Structure reference
   * @param i index of item in the array
   * @return value at index i in the array 
   */
  public String getProc_dirs(int addr, int i) {
        if (featOkTst && casFeat_proc_dirs == null)
      jcas.throwFeatMissing("proc_dirs", "edu.columbia.incite.uima.api.types.obo.Session");
    if (lowLevelTypeChecks)
      return ll_cas.ll_getStringArrayValue(ll_cas.ll_getRefValue(addr, casFeatCode_proc_dirs), i, true);
    jcas.checkArrayBounds(ll_cas.ll_getRefValue(addr, casFeatCode_proc_dirs), i);
	return ll_cas.ll_getStringArrayValue(ll_cas.ll_getRefValue(addr, casFeatCode_proc_dirs), i);
  }
   
  /** @generated
   * @param addr low level Feature Structure reference
   * @param i index of item in the array
   * @param v value to set
   */ 
  public void setProc_dirs(int addr, int i, String v) {
        if (featOkTst && casFeat_proc_dirs == null)
      jcas.throwFeatMissing("proc_dirs", "edu.columbia.incite.uima.api.types.obo.Session");
    if (lowLevelTypeChecks)
      ll_cas.ll_setStringArrayValue(ll_cas.ll_getRefValue(addr, casFeatCode_proc_dirs), i, v, true);
    jcas.checkArrayBounds(ll_cas.ll_getRefValue(addr, casFeatCode_proc_dirs), i);
    ll_cas.ll_setStringArrayValue(ll_cas.ll_getRefValue(addr, casFeatCode_proc_dirs), i, v);
  }
 



  /** initialize variables to correspond with Cas Type and Features
	 * @generated
	 * @param jcas JCas
	 * @param casType Type 
	 */
  public Session_Type(JCas jcas, Type casType) {
    super(jcas, casType);
    casImpl.getFSClassRegistry().addGeneratorForType((TypeImpl)this.casType, getFSGenerator());

 
    casFeat_proc_dupes = jcas.getRequiredFeatureDE(casType, "proc_dupes", "uima.cas.StringArray", featOkTst);
    casFeatCode_proc_dupes  = (null == casFeat_proc_dupes) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_proc_dupes).getCode();

 
    casFeat_proc_does = jcas.getRequiredFeatureDE(casType, "proc_does", "uima.cas.StringArray", featOkTst);
    casFeatCode_proc_does  = (null == casFeat_proc_does) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_proc_does).getCode();

 
    casFeat_proc_dirs = jcas.getRequiredFeatureDE(casType, "proc_dirs", "uima.cas.StringArray", featOkTst);
    casFeatCode_proc_dirs  = (null == casFeat_proc_dirs) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_proc_dirs).getCode();

  }
}



    