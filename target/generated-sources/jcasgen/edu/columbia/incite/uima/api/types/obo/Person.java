

/* First created by JCasGen Mon Jun 18 18:20:05 CLT 2018 */
package edu.columbia.incite.uima.api.types.obo;

import org.apache.uima.jcas.JCas; 
import org.apache.uima.jcas.JCasRegistry;
import org.apache.uima.jcas.cas.TOP_Type;



/** Personal names
 * Updated by JCasGen Mon Jun 18 18:20:05 CLT 2018
 * XML source: /home/jta/src/local/obo/obo-java/target/jcasgen/typesystem.xml
 * @generated */
public class Person extends Named {
  /** @generated
   * @ordered 
   */
  @SuppressWarnings ("hiding")
  public final static int typeIndexID = JCasRegistry.register(Person.class);
  /** @generated
   * @ordered 
   */
  @SuppressWarnings ("hiding")
  public final static int type = typeIndexID;
  /** @generated
   * @return index of the type  
   */
  @Override
  public              int getTypeIndexID() {return typeIndexID;}
 
  /** Never called.  Disable default constructor
   * @generated */
  protected Person() {/* intentionally empty block */}
    
  /** Internal - constructor used by generator 
   * @generated
   * @param addr low level Feature Structure reference
   * @param type the type of this Feature Structure 
   */
  public Person(int addr, TOP_Type type) {
    super(addr, type);
    readObject();
  }
  
  /** @generated
   * @param jcas JCas to which this Feature Structure belongs 
   */
  public Person(JCas jcas) {
    super(jcas);
    readObject();   
  } 

  /** @generated
   * @param jcas JCas to which this Feature Structure belongs
   * @param begin offset to the begin spot in the SofA
   * @param end offset to the end spot in the SofA 
  */  
  public Person(JCas jcas, int begin, int end) {
    super(jcas);
    setBegin(begin);
    setEnd(end);
    readObject();
  }   

  /** 
   * <!-- begin-user-doc -->
   * Write your own initialization here
   * <!-- end-user-doc -->
   *
   * @generated modifiable 
   */
  private void readObject() {/*default - does nothing empty block */}
     
 
    
  //*--------------*
  //* Feature: given

  /** getter for given - gets Given name
   * @generated
   * @return value of the feature 
   */
  public String getGiven() {
    if (Person_Type.featOkTst && ((Person_Type)jcasType).casFeat_given == null)
      jcasType.jcas.throwFeatMissing("given", "edu.columbia.incite.uima.api.types.obo.Person");
    return jcasType.ll_cas.ll_getStringValue(addr, ((Person_Type)jcasType).casFeatCode_given);}
    
  /** setter for given - sets Given name 
   * @generated
   * @param v value to set into the feature 
   */
  public void setGiven(String v) {
    if (Person_Type.featOkTst && ((Person_Type)jcasType).casFeat_given == null)
      jcasType.jcas.throwFeatMissing("given", "edu.columbia.incite.uima.api.types.obo.Person");
    jcasType.ll_cas.ll_setStringValue(addr, ((Person_Type)jcasType).casFeatCode_given, v);}    
   
    
  //*--------------*
  //* Feature: surname

  /** getter for surname - gets Surname
   * @generated
   * @return value of the feature 
   */
  public String getSurname() {
    if (Person_Type.featOkTst && ((Person_Type)jcasType).casFeat_surname == null)
      jcasType.jcas.throwFeatMissing("surname", "edu.columbia.incite.uima.api.types.obo.Person");
    return jcasType.ll_cas.ll_getStringValue(addr, ((Person_Type)jcasType).casFeatCode_surname);}
    
  /** setter for surname - sets Surname 
   * @generated
   * @param v value to set into the feature 
   */
  public void setSurname(String v) {
    if (Person_Type.featOkTst && ((Person_Type)jcasType).casFeat_surname == null)
      jcasType.jcas.throwFeatMissing("surname", "edu.columbia.incite.uima.api.types.obo.Person");
    jcasType.ll_cas.ll_setStringValue(addr, ((Person_Type)jcasType).casFeatCode_surname, v);}    
   
    
  //*--------------*
  //* Feature: gender

  /** getter for gender - gets Gender
   * @generated
   * @return value of the feature 
   */
  public String getGender() {
    if (Person_Type.featOkTst && ((Person_Type)jcasType).casFeat_gender == null)
      jcasType.jcas.throwFeatMissing("gender", "edu.columbia.incite.uima.api.types.obo.Person");
    return jcasType.ll_cas.ll_getStringValue(addr, ((Person_Type)jcasType).casFeatCode_gender);}
    
  /** setter for gender - sets Gender 
   * @generated
   * @param v value to set into the feature 
   */
  public void setGender(String v) {
    if (Person_Type.featOkTst && ((Person_Type)jcasType).casFeat_gender == null)
      jcasType.jcas.throwFeatMissing("gender", "edu.columbia.incite.uima.api.types.obo.Person");
    jcasType.ll_cas.ll_setStringValue(addr, ((Person_Type)jcasType).casFeatCode_gender, v);}    
   
    
  //*--------------*
  //* Feature: age

  /** getter for age - gets Age
   * @generated
   * @return value of the feature 
   */
  public String getAge() {
    if (Person_Type.featOkTst && ((Person_Type)jcasType).casFeat_age == null)
      jcasType.jcas.throwFeatMissing("age", "edu.columbia.incite.uima.api.types.obo.Person");
    return jcasType.ll_cas.ll_getStringValue(addr, ((Person_Type)jcasType).casFeatCode_age);}
    
  /** setter for age - sets Age 
   * @generated
   * @param v value to set into the feature 
   */
  public void setAge(String v) {
    if (Person_Type.featOkTst && ((Person_Type)jcasType).casFeat_age == null)
      jcasType.jcas.throwFeatMissing("age", "edu.columbia.incite.uima.api.types.obo.Person");
    jcasType.ll_cas.ll_setStringValue(addr, ((Person_Type)jcasType).casFeatCode_age, v);}    
   
    
  //*--------------*
  //* Feature: occupation

  /** getter for occupation - gets Occupation
   * @generated
   * @return value of the feature 
   */
  public String getOccupation() {
    if (Person_Type.featOkTst && ((Person_Type)jcasType).casFeat_occupation == null)
      jcasType.jcas.throwFeatMissing("occupation", "edu.columbia.incite.uima.api.types.obo.Person");
    return jcasType.ll_cas.ll_getStringValue(addr, ((Person_Type)jcasType).casFeatCode_occupation);}
    
  /** setter for occupation - sets Occupation 
   * @generated
   * @param v value to set into the feature 
   */
  public void setOccupation(String v) {
    if (Person_Type.featOkTst && ((Person_Type)jcasType).casFeat_occupation == null)
      jcasType.jcas.throwFeatMissing("occupation", "edu.columbia.incite.uima.api.types.obo.Person");
    jcasType.ll_cas.ll_setStringValue(addr, ((Person_Type)jcasType).casFeatCode_occupation, v);}    
  }

    