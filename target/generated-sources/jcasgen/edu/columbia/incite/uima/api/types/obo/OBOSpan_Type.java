
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
import edu.columbia.incite.uima.api.types.Span_Type;

/** Base type for OBO span annotations
 * Updated by JCasGen Mon Jun 18 18:20:05 CLT 2018
 * @generated */
public class OBOSpan_Type extends Span_Type {
  /** @generated 
   * @return the generator for this type
   */
  @Override
  protected FSGenerator getFSGenerator() {return fsGenerator;}
  /** @generated */
  private final FSGenerator fsGenerator = 
    new FSGenerator() {
      public FeatureStructure createFS(int addr, CASImpl cas) {
  			 if (OBOSpan_Type.this.useExistingInstance) {
  			   // Return eq fs instance if already created
  		     FeatureStructure fs = OBOSpan_Type.this.jcas.getJfsFromCaddr(addr);
  		     if (null == fs) {
  		       fs = new OBOSpan(addr, OBOSpan_Type.this);
  			   OBOSpan_Type.this.jcas.putJfsFromCaddr(addr, fs);
  			   return fs;
  		     }
  		     return fs;
        } else return new OBOSpan(addr, OBOSpan_Type.this);
  	  }
    };
  /** @generated */
  @SuppressWarnings ("hiding")
  public final static int typeIndexID = OBOSpan.typeIndexID;
  /** @generated 
     @modifiable */
  @SuppressWarnings ("hiding")
  public final static boolean featOkTst = JCasRegistry.getFeatOkTst("edu.columbia.incite.uima.api.types.obo.OBOSpan");
 
  /** @generated */
  final Feature casFeat_oboType;
  /** @generated */
  final int     casFeatCode_oboType;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public String getOboType(int addr) {
        if (featOkTst && casFeat_oboType == null)
      jcas.throwFeatMissing("oboType", "edu.columbia.incite.uima.api.types.obo.OBOSpan");
    return ll_cas.ll_getStringValue(addr, casFeatCode_oboType);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setOboType(int addr, String v) {
        if (featOkTst && casFeat_oboType == null)
      jcas.throwFeatMissing("oboType", "edu.columbia.incite.uima.api.types.obo.OBOSpan");
    ll_cas.ll_setStringValue(addr, casFeatCode_oboType, v);}
    
  
 
  /** @generated */
  final Feature casFeat_xpath;
  /** @generated */
  final int     casFeatCode_xpath;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public String getXpath(int addr) {
        if (featOkTst && casFeat_xpath == null)
      jcas.throwFeatMissing("xpath", "edu.columbia.incite.uima.api.types.obo.OBOSpan");
    return ll_cas.ll_getStringValue(addr, casFeatCode_xpath);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setXpath(int addr, String v) {
        if (featOkTst && casFeat_xpath == null)
      jcas.throwFeatMissing("xpath", "edu.columbia.incite.uima.api.types.obo.OBOSpan");
    ll_cas.ll_setStringValue(addr, casFeatCode_xpath, v);}
    
  



  /** initialize variables to correspond with Cas Type and Features
	 * @generated
	 * @param jcas JCas
	 * @param casType Type 
	 */
  public OBOSpan_Type(JCas jcas, Type casType) {
    super(jcas, casType);
    casImpl.getFSClassRegistry().addGeneratorForType((TypeImpl)this.casType, getFSGenerator());

 
    casFeat_oboType = jcas.getRequiredFeatureDE(casType, "oboType", "uima.cas.String", featOkTst);
    casFeatCode_oboType  = (null == casFeat_oboType) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_oboType).getCode();

 
    casFeat_xpath = jcas.getRequiredFeatureDE(casType, "xpath", "uima.cas.String", featOkTst);
    casFeatCode_xpath  = (null == casFeat_xpath) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_xpath).getCode();

  }
}



    