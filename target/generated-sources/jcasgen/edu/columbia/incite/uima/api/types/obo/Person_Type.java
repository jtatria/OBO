
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

/** Personal names
 * Updated by JCasGen Mon Jun 18 18:20:05 CLT 2018
 * @generated */
public class Person_Type extends Named_Type {
  /** @generated 
   * @return the generator for this type
   */
  @Override
  protected FSGenerator getFSGenerator() {return fsGenerator;}
  /** @generated */
  private final FSGenerator fsGenerator = 
    new FSGenerator() {
      public FeatureStructure createFS(int addr, CASImpl cas) {
  			 if (Person_Type.this.useExistingInstance) {
  			   // Return eq fs instance if already created
  		     FeatureStructure fs = Person_Type.this.jcas.getJfsFromCaddr(addr);
  		     if (null == fs) {
  		       fs = new Person(addr, Person_Type.this);
  			   Person_Type.this.jcas.putJfsFromCaddr(addr, fs);
  			   return fs;
  		     }
  		     return fs;
        } else return new Person(addr, Person_Type.this);
  	  }
    };
  /** @generated */
  @SuppressWarnings ("hiding")
  public final static int typeIndexID = Person.typeIndexID;
  /** @generated 
     @modifiable */
  @SuppressWarnings ("hiding")
  public final static boolean featOkTst = JCasRegistry.getFeatOkTst("edu.columbia.incite.uima.api.types.obo.Person");
 
  /** @generated */
  final Feature casFeat_given;
  /** @generated */
  final int     casFeatCode_given;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public String getGiven(int addr) {
        if (featOkTst && casFeat_given == null)
      jcas.throwFeatMissing("given", "edu.columbia.incite.uima.api.types.obo.Person");
    return ll_cas.ll_getStringValue(addr, casFeatCode_given);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setGiven(int addr, String v) {
        if (featOkTst && casFeat_given == null)
      jcas.throwFeatMissing("given", "edu.columbia.incite.uima.api.types.obo.Person");
    ll_cas.ll_setStringValue(addr, casFeatCode_given, v);}
    
  
 
  /** @generated */
  final Feature casFeat_surname;
  /** @generated */
  final int     casFeatCode_surname;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public String getSurname(int addr) {
        if (featOkTst && casFeat_surname == null)
      jcas.throwFeatMissing("surname", "edu.columbia.incite.uima.api.types.obo.Person");
    return ll_cas.ll_getStringValue(addr, casFeatCode_surname);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setSurname(int addr, String v) {
        if (featOkTst && casFeat_surname == null)
      jcas.throwFeatMissing("surname", "edu.columbia.incite.uima.api.types.obo.Person");
    ll_cas.ll_setStringValue(addr, casFeatCode_surname, v);}
    
  
 
  /** @generated */
  final Feature casFeat_gender;
  /** @generated */
  final int     casFeatCode_gender;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public String getGender(int addr) {
        if (featOkTst && casFeat_gender == null)
      jcas.throwFeatMissing("gender", "edu.columbia.incite.uima.api.types.obo.Person");
    return ll_cas.ll_getStringValue(addr, casFeatCode_gender);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setGender(int addr, String v) {
        if (featOkTst && casFeat_gender == null)
      jcas.throwFeatMissing("gender", "edu.columbia.incite.uima.api.types.obo.Person");
    ll_cas.ll_setStringValue(addr, casFeatCode_gender, v);}
    
  
 
  /** @generated */
  final Feature casFeat_age;
  /** @generated */
  final int     casFeatCode_age;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public String getAge(int addr) {
        if (featOkTst && casFeat_age == null)
      jcas.throwFeatMissing("age", "edu.columbia.incite.uima.api.types.obo.Person");
    return ll_cas.ll_getStringValue(addr, casFeatCode_age);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setAge(int addr, String v) {
        if (featOkTst && casFeat_age == null)
      jcas.throwFeatMissing("age", "edu.columbia.incite.uima.api.types.obo.Person");
    ll_cas.ll_setStringValue(addr, casFeatCode_age, v);}
    
  
 
  /** @generated */
  final Feature casFeat_occupation;
  /** @generated */
  final int     casFeatCode_occupation;
  /** @generated
   * @param addr low level Feature Structure reference
   * @return the feature value 
   */ 
  public String getOccupation(int addr) {
        if (featOkTst && casFeat_occupation == null)
      jcas.throwFeatMissing("occupation", "edu.columbia.incite.uima.api.types.obo.Person");
    return ll_cas.ll_getStringValue(addr, casFeatCode_occupation);
  }
  /** @generated
   * @param addr low level Feature Structure reference
   * @param v value to set 
   */    
  public void setOccupation(int addr, String v) {
        if (featOkTst && casFeat_occupation == null)
      jcas.throwFeatMissing("occupation", "edu.columbia.incite.uima.api.types.obo.Person");
    ll_cas.ll_setStringValue(addr, casFeatCode_occupation, v);}
    
  



  /** initialize variables to correspond with Cas Type and Features
	 * @generated
	 * @param jcas JCas
	 * @param casType Type 
	 */
  public Person_Type(JCas jcas, Type casType) {
    super(jcas, casType);
    casImpl.getFSClassRegistry().addGeneratorForType((TypeImpl)this.casType, getFSGenerator());

 
    casFeat_given = jcas.getRequiredFeatureDE(casType, "given", "uima.cas.String", featOkTst);
    casFeatCode_given  = (null == casFeat_given) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_given).getCode();

 
    casFeat_surname = jcas.getRequiredFeatureDE(casType, "surname", "uima.cas.String", featOkTst);
    casFeatCode_surname  = (null == casFeat_surname) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_surname).getCode();

 
    casFeat_gender = jcas.getRequiredFeatureDE(casType, "gender", "uima.cas.String", featOkTst);
    casFeatCode_gender  = (null == casFeat_gender) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_gender).getCode();

 
    casFeat_age = jcas.getRequiredFeatureDE(casType, "age", "uima.cas.String", featOkTst);
    casFeatCode_age  = (null == casFeat_age) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_age).getCode();

 
    casFeat_occupation = jcas.getRequiredFeatureDE(casType, "occupation", "uima.cas.String", featOkTst);
    casFeatCode_occupation  = (null == casFeat_occupation) ? JCas.INVALID_FEATURE_CODE : ((FeatureImpl)casFeat_occupation).getCode();

  }
}



    