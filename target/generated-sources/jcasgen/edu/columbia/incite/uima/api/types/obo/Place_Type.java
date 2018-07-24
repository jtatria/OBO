
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

/** Place name
 * Updated by JCasGen Mon Jun 18 18:20:05 CLT 2018
 * @generated */
public class Place_Type extends Named_Type {
  /** @generated 
   * @return the generator for this type
   */
  @Override
  protected FSGenerator getFSGenerator() {return fsGenerator;}
  /** @generated */
  private final FSGenerator fsGenerator = 
    new FSGenerator() {
      public FeatureStructure createFS(int addr, CASImpl cas) {
  			 if (Place_Type.this.useExistingInstance) {
  			   // Return eq fs instance if already created
  		     FeatureStructure fs = Place_Type.this.jcas.getJfsFromCaddr(addr);
  		     if (null == fs) {
  		       fs = new Place(addr, Place_Type.this);
  			   Place_Type.this.jcas.putJfsFromCaddr(addr, fs);
  			   return fs;
  		     }
  		     return fs;
        } else return new Place(addr, Place_Type.this);
  	  }
    };
  /** @generated */
  @SuppressWarnings ("hiding")
  public final static int typeIndexID = Place.typeIndexID;
  /** @generated 
     @modifiable */
  @SuppressWarnings ("hiding")
  public final static boolean featOkTst = JCasRegistry.getFeatOkTst("edu.columbia.incite.uima.api.types.obo.Place");
 
  /** @generated */
  final Feature casFeat_placeName;
  /** @generated */
  final int     casFeatCode_placeName;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public String getPlaceName(int addr) {
        if (featOkTst && casFeat_placeName == null)
      jcas.throwFeatMissing("placeName", "edu.columbia.incite.uima.api.types.obo.Place");
    return ll_cas.ll_getStringValue(addr, casFeatCode_placeName);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setPlaceName(int addr, String v) {
        if (featOkTst && casFeat_placeName == null)
      jcas.throwFeatMissing("placeName", "edu.columbia.incite.uima.api.types.obo.Place");
    ll_cas.ll_setStringValue(addr, casFeatCode_placeName, v);}
    
  
 
  /** @generated */
  final Feature casFeat_placeType;
  /** @generated */
  final int     casFeatCode_placeType;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public String getPlaceType(int addr) {
        if (featOkTst && casFeat_placeType == null)
      jcas.throwFeatMissing("placeType", "edu.columbia.incite.uima.api.types.obo.Place");
    return ll_cas.ll_getStringValue(addr, casFeatCode_placeType);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setPlaceType(int addr, String v) {
        if (featOkTst && casFeat_placeType == null)
      jcas.throwFeatMissing("placeType", "edu.columbia.incite.uima.api.types.obo.Place");
    ll_cas.ll_setStringValue(addr, casFeatCode_placeType, v);}
    
  



  /** initialize variables to correspond with Cas Type and Features
	 * @generated
	 * @param jcas JCas
	 * @param casType Type 
	 */
  public Place_Type(JCas jcas, Type casType) {
    super(jcas, casType);
    casImpl.getFSClassRegistry().addGeneratorForType((TypeImpl)this.casType, getFSGenerator());

 
    casFeat_placeName = jcas.getRequiredFeatureDE(casType, "placeName", "uima.cas.String", featOkTst);
    casFeatCode_placeName  = (null == casFeat_placeName) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_placeName).getCode();

 
    casFeat_placeType = jcas.getRequiredFeatureDE(casType, "placeType", "uima.cas.String", featOkTst);
    casFeatCode_placeType  = (null == casFeat_placeType) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_placeType).getCode();

  }
}



    