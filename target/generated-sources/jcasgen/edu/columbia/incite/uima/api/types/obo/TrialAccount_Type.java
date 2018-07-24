
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

/** Trial accounts
 * Updated by JCasGen Mon Jun 18 18:20:05 CLT 2018
 * @generated */
public class TrialAccount_Type extends Section_Type {
  /** @generated 
   * @return the generator for this type
   */
  @Override
  protected FSGenerator getFSGenerator() {return fsGenerator;}
  /** @generated */
  private final FSGenerator fsGenerator = 
    new FSGenerator() {
      public FeatureStructure createFS(int addr, CASImpl cas) {
  			 if (TrialAccount_Type.this.useExistingInstance) {
  			   // Return eq fs instance if already created
  		     FeatureStructure fs = TrialAccount_Type.this.jcas.getJfsFromCaddr(addr);
  		     if (null == fs) {
  		       fs = new TrialAccount(addr, TrialAccount_Type.this);
  			   TrialAccount_Type.this.jcas.putJfsFromCaddr(addr, fs);
  			   return fs;
  		     }
  		     return fs;
        } else return new TrialAccount(addr, TrialAccount_Type.this);
  	  }
    };
  /** @generated */
  @SuppressWarnings ("hiding")
  public final static int typeIndexID = TrialAccount.typeIndexID;
  /** @generated 
     @modifiable */
  @SuppressWarnings ("hiding")
  public final static boolean featOkTst = JCasRegistry.getFeatOkTst("edu.columbia.incite.uima.api.types.obo.TrialAccount");
 
  /** @generated */
  final Feature casFeat_charges;
  /** @generated */
  final int     casFeatCode_charges;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public int getCharges(int addr) {
        if (featOkTst && casFeat_charges == null)
      jcas.throwFeatMissing("charges", "edu.columbia.incite.uima.api.types.obo.TrialAccount");
    return ll_cas.ll_getRefValue(addr, casFeatCode_charges);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setCharges(int addr, int v) {
        if (featOkTst && casFeat_charges == null)
      jcas.throwFeatMissing("charges", "edu.columbia.incite.uima.api.types.obo.TrialAccount");
    ll_cas.ll_setRefValue(addr, casFeatCode_charges, v);}
    
   /** @generated
   * @param addr low level Feature Structure reference
   * @param i index of item in the array
   * @return value at index i in the array 
   */
  public int getCharges(int addr, int i) {
        if (featOkTst && casFeat_charges == null)
      jcas.throwFeatMissing("charges", "edu.columbia.incite.uima.api.types.obo.TrialAccount");
    if (lowLevelTypeChecks)
      return ll_cas.ll_getRefArrayValue(ll_cas.ll_getRefValue(addr, casFeatCode_charges), i, true);
    jcas.checkArrayBounds(ll_cas.ll_getRefValue(addr, casFeatCode_charges), i);
	return ll_cas.ll_getRefArrayValue(ll_cas.ll_getRefValue(addr, casFeatCode_charges), i);
  }
   
  /** @generated
   * @param addr low level Feature Structure reference
   * @param i index of item in the array
   * @param v value to set
   */ 
  public void setCharges(int addr, int i, int v) {
        if (featOkTst && casFeat_charges == null)
      jcas.throwFeatMissing("charges", "edu.columbia.incite.uima.api.types.obo.TrialAccount");
    if (lowLevelTypeChecks)
      ll_cas.ll_setRefArrayValue(ll_cas.ll_getRefValue(addr, casFeatCode_charges), i, v, true);
    jcas.checkArrayBounds(ll_cas.ll_getRefValue(addr, casFeatCode_charges), i);
    ll_cas.ll_setRefArrayValue(ll_cas.ll_getRefValue(addr, casFeatCode_charges), i, v);
  }
 



  /** initialize variables to correspond with Cas Type and Features
	 * @generated
	 * @param jcas JCas
	 * @param casType Type 
	 */
  public TrialAccount_Type(JCas jcas, Type casType) {
    super(jcas, casType);
    casImpl.getFSClassRegistry().addGeneratorForType((TypeImpl)this.casType, getFSGenerator());

 
    casFeat_charges = jcas.getRequiredFeatureDE(casType, "charges", "uima.cas.FSArray", featOkTst);
    casFeatCode_charges  = (null == casFeat_charges) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_charges).getCode();

  }
}



    