
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
import org.apache.uima.jcas.cas.AnnotationBase_Type;

/** Criminal charge
 * Updated by JCasGen Mon Jun 18 18:20:05 CLT 2018
 * @generated */
public class Charge_Type extends AnnotationBase_Type {
  /** @generated 
   * @return the generator for this type
   */
  @Override
  protected FSGenerator getFSGenerator() {return fsGenerator;}
  /** @generated */
  private final FSGenerator fsGenerator = 
    new FSGenerator() {
      public FeatureStructure createFS(int addr, CASImpl cas) {
  			 if (Charge_Type.this.useExistingInstance) {
  			   // Return eq fs instance if already created
  		     FeatureStructure fs = Charge_Type.this.jcas.getJfsFromCaddr(addr);
  		     if (null == fs) {
  		       fs = new Charge(addr, Charge_Type.this);
  			   Charge_Type.this.jcas.putJfsFromCaddr(addr, fs);
  			   return fs;
  		     }
  		     return fs;
        } else return new Charge(addr, Charge_Type.this);
  	  }
    };
  /** @generated */
  @SuppressWarnings ("hiding")
  public final static int typeIndexID = Charge.typeIndexID;
  /** @generated 
     @modifiable */
  @SuppressWarnings ("hiding")
  public final static boolean featOkTst = JCasRegistry.getFeatOkTst("edu.columbia.incite.uima.api.types.obo.Charge");
 
  /** @generated */
  final Feature casFeat_chargeId;
  /** @generated */
  final int     casFeatCode_chargeId;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public String getChargeId(int addr) {
        if (featOkTst && casFeat_chargeId == null)
      jcas.throwFeatMissing("chargeId", "edu.columbia.incite.uima.api.types.obo.Charge");
    return ll_cas.ll_getStringValue(addr, casFeatCode_chargeId);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setChargeId(int addr, String v) {
        if (featOkTst && casFeat_chargeId == null)
      jcas.throwFeatMissing("chargeId", "edu.columbia.incite.uima.api.types.obo.Charge");
    ll_cas.ll_setStringValue(addr, casFeatCode_chargeId, v);}
    
  
 
  /** @generated */
  final Feature casFeat_defendant;
  /** @generated */
  final int     casFeatCode_defendant;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public int getDefendant(int addr) {
        if (featOkTst && casFeat_defendant == null)
      jcas.throwFeatMissing("defendant", "edu.columbia.incite.uima.api.types.obo.Charge");
    return ll_cas.ll_getRefValue(addr, casFeatCode_defendant);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setDefendant(int addr, int v) {
        if (featOkTst && casFeat_defendant == null)
      jcas.throwFeatMissing("defendant", "edu.columbia.incite.uima.api.types.obo.Charge");
    ll_cas.ll_setRefValue(addr, casFeatCode_defendant, v);}
    
  
 
  /** @generated */
  final Feature casFeat_offence;
  /** @generated */
  final int     casFeatCode_offence;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public int getOffence(int addr) {
        if (featOkTst && casFeat_offence == null)
      jcas.throwFeatMissing("offence", "edu.columbia.incite.uima.api.types.obo.Charge");
    return ll_cas.ll_getRefValue(addr, casFeatCode_offence);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setOffence(int addr, int v) {
        if (featOkTst && casFeat_offence == null)
      jcas.throwFeatMissing("offence", "edu.columbia.incite.uima.api.types.obo.Charge");
    ll_cas.ll_setRefValue(addr, casFeatCode_offence, v);}
    
  
 
  /** @generated */
  final Feature casFeat_verdict;
  /** @generated */
  final int     casFeatCode_verdict;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public int getVerdict(int addr) {
        if (featOkTst && casFeat_verdict == null)
      jcas.throwFeatMissing("verdict", "edu.columbia.incite.uima.api.types.obo.Charge");
    return ll_cas.ll_getRefValue(addr, casFeatCode_verdict);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setVerdict(int addr, int v) {
        if (featOkTst && casFeat_verdict == null)
      jcas.throwFeatMissing("verdict", "edu.columbia.incite.uima.api.types.obo.Charge");
    ll_cas.ll_setRefValue(addr, casFeatCode_verdict, v);}
    
  



  /** initialize variables to correspond with Cas Type and Features
	 * @generated
	 * @param jcas JCas
	 * @param casType Type 
	 */
  public Charge_Type(JCas jcas, Type casType) {
    super(jcas, casType);
    casImpl.getFSClassRegistry().addGeneratorForType((TypeImpl)this.casType, getFSGenerator());

 
    casFeat_chargeId = jcas.getRequiredFeatureDE(casType, "chargeId", "uima.cas.String", featOkTst);
    casFeatCode_chargeId  = (null == casFeat_chargeId) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_chargeId).getCode();

 
    casFeat_defendant = jcas.getRequiredFeatureDE(casType, "defendant", "edu.columbia.incite.uima.api.types.obo.Person", featOkTst);
    casFeatCode_defendant  = (null == casFeat_defendant) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_defendant).getCode();

 
    casFeat_offence = jcas.getRequiredFeatureDE(casType, "offence", "edu.columbia.incite.uima.api.types.obo.Offence", featOkTst);
    casFeatCode_offence  = (null == casFeat_offence) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_offence).getCode();

 
    casFeat_verdict = jcas.getRequiredFeatureDE(casType, "verdict", "edu.columbia.incite.uima.api.types.obo.Verdict", featOkTst);
    casFeatCode_verdict  = (null == casFeat_verdict) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_verdict).getCode();

  }
}



    