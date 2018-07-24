
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

/** Base type for legal entities
 * Updated by JCasGen Mon Jun 18 18:20:05 CLT 2018
 * @generated */
public class Legal_Type extends OBOEntity_Type {
  /** @generated 
   * @return the generator for this type
   */
  @Override
  protected FSGenerator getFSGenerator() {return fsGenerator;}
  /** @generated */
  private final FSGenerator fsGenerator = 
    new FSGenerator() {
      public FeatureStructure createFS(int addr, CASImpl cas) {
  			 if (Legal_Type.this.useExistingInstance) {
  			   // Return eq fs instance if already created
  		     FeatureStructure fs = Legal_Type.this.jcas.getJfsFromCaddr(addr);
  		     if (null == fs) {
  		       fs = new Legal(addr, Legal_Type.this);
  			   Legal_Type.this.jcas.putJfsFromCaddr(addr, fs);
  			   return fs;
  		     }
  		     return fs;
        } else return new Legal(addr, Legal_Type.this);
  	  }
    };
  /** @generated */
  @SuppressWarnings ("hiding")
  public final static int typeIndexID = Legal.typeIndexID;
  /** @generated 
     @modifiable */
  @SuppressWarnings ("hiding")
  public final static boolean featOkTst = JCasRegistry.getFeatOkTst("edu.columbia.incite.uima.api.types.obo.Legal");
 
  /** @generated */
  final Feature casFeat_category;
  /** @generated */
  final int     casFeatCode_category;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public String getCategory(int addr) {
        if (featOkTst && casFeat_category == null)
      jcas.throwFeatMissing("category", "edu.columbia.incite.uima.api.types.obo.Legal");
    return ll_cas.ll_getStringValue(addr, casFeatCode_category);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setCategory(int addr, String v) {
        if (featOkTst && casFeat_category == null)
      jcas.throwFeatMissing("category", "edu.columbia.incite.uima.api.types.obo.Legal");
    ll_cas.ll_setStringValue(addr, casFeatCode_category, v);}
    
  
 
  /** @generated */
  final Feature casFeat_subcategory;
  /** @generated */
  final int     casFeatCode_subcategory;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public String getSubcategory(int addr) {
        if (featOkTst && casFeat_subcategory == null)
      jcas.throwFeatMissing("subcategory", "edu.columbia.incite.uima.api.types.obo.Legal");
    return ll_cas.ll_getStringValue(addr, casFeatCode_subcategory);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setSubcategory(int addr, String v) {
        if (featOkTst && casFeat_subcategory == null)
      jcas.throwFeatMissing("subcategory", "edu.columbia.incite.uima.api.types.obo.Legal");
    ll_cas.ll_setStringValue(addr, casFeatCode_subcategory, v);}
    
  



  /** initialize variables to correspond with Cas Type and Features
	 * @generated
	 * @param jcas JCas
	 * @param casType Type 
	 */
  public Legal_Type(JCas jcas, Type casType) {
    super(jcas, casType);
    casImpl.getFSClassRegistry().addGeneratorForType((TypeImpl)this.casType, getFSGenerator());

 
    casFeat_category = jcas.getRequiredFeatureDE(casType, "category", "uima.cas.String", featOkTst);
    casFeatCode_category  = (null == casFeat_category) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_category).getCode();

 
    casFeat_subcategory = jcas.getRequiredFeatureDE(casType, "subcategory", "uima.cas.String", featOkTst);
    casFeatCode_subcategory  = (null == casFeat_subcategory) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_subcategory).getCode();

  }
}



    