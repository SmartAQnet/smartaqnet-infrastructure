/**
 * Autogenerated by Avro
 *
 * DO NOT EDIT DIRECTLY
 */
package pw.oliver.jmkb.avroclasses;

import org.apache.avro.specific.SpecificData;
import org.apache.avro.message.BinaryMessageEncoder;
import org.apache.avro.message.BinaryMessageDecoder;
import org.apache.avro.message.SchemaStore;

@SuppressWarnings("all")
/** The Unit of Measurement of an Observation */
@org.apache.avro.specific.AvroGenerated
public class UnitOfMeasurement extends org.apache.avro.specific.SpecificRecordBase implements org.apache.avro.specific.SpecificRecord {
  private static final long serialVersionUID = -7778233652719082149L;
  public static final org.apache.avro.Schema SCHEMA$ = new org.apache.avro.Schema.Parser().parse("{\"type\":\"record\",\"name\":\"UnitOfMeasurement\",\"namespace\":\"pw.oliver.jmkb.avroclasses\",\"doc\":\"The Unit of Measurement of an Observation\",\"fields\":[{\"name\":\"name\",\"type\":\"string\",\"doc\":\"String representation of the Unit of Measurement\"},{\"name\":\"symbol\",\"type\":\"string\",\"doc\":\"Symbol of the Unit of Measurement\"},{\"name\":\"definition\",\"type\":\"string\",\"doc\":\"Definition of the Unit of Measurement\"}]}");
  public static org.apache.avro.Schema getClassSchema() { return SCHEMA$; }

  private static SpecificData MODEL$ = new SpecificData();

  private static final BinaryMessageEncoder<UnitOfMeasurement> ENCODER =
      new BinaryMessageEncoder<UnitOfMeasurement>(MODEL$, SCHEMA$);

  private static final BinaryMessageDecoder<UnitOfMeasurement> DECODER =
      new BinaryMessageDecoder<UnitOfMeasurement>(MODEL$, SCHEMA$);

  /**
   * Return the BinaryMessageDecoder instance used by this class.
   */
  public static BinaryMessageDecoder<UnitOfMeasurement> getDecoder() {
    return DECODER;
  }

  /**
   * Create a new BinaryMessageDecoder instance for this class that uses the specified {@link SchemaStore}.
   * @param resolver a {@link SchemaStore} used to find schemas by fingerprint
   */
  public static BinaryMessageDecoder<UnitOfMeasurement> createDecoder(SchemaStore resolver) {
    return new BinaryMessageDecoder<UnitOfMeasurement>(MODEL$, SCHEMA$, resolver);
  }

  /** Serializes this UnitOfMeasurement to a ByteBuffer. */
  public java.nio.ByteBuffer toByteBuffer() throws java.io.IOException {
    return ENCODER.encode(this);
  }

  /** Deserializes a UnitOfMeasurement from a ByteBuffer. */
  public static UnitOfMeasurement fromByteBuffer(
      java.nio.ByteBuffer b) throws java.io.IOException {
    return DECODER.decode(b);
  }

  /** String representation of the Unit of Measurement */
  @Deprecated public java.lang.CharSequence name;
  /** Symbol of the Unit of Measurement */
  @Deprecated public java.lang.CharSequence symbol;
  /** Definition of the Unit of Measurement */
  @Deprecated public java.lang.CharSequence definition;

  /**
   * Default constructor.  Note that this does not initialize fields
   * to their default values from the schema.  If that is desired then
   * one should use <code>newBuilder()</code>.
   */
  public UnitOfMeasurement() {}

  /**
   * All-args constructor.
   * @param name String representation of the Unit of Measurement
   * @param symbol Symbol of the Unit of Measurement
   * @param definition Definition of the Unit of Measurement
   */
  public UnitOfMeasurement(java.lang.CharSequence name, java.lang.CharSequence symbol, java.lang.CharSequence definition) {
    this.name = name;
    this.symbol = symbol;
    this.definition = definition;
  }

  public org.apache.avro.Schema getSchema() { return SCHEMA$; }
  // Used by DatumWriter.  Applications should not call.
  public java.lang.Object get(int field$) {
    switch (field$) {
    case 0: return name;
    case 1: return symbol;
    case 2: return definition;
    default: throw new org.apache.avro.AvroRuntimeException("Bad index");
    }
  }

  // Used by DatumReader.  Applications should not call.
  @SuppressWarnings(value="unchecked")
  public void put(int field$, java.lang.Object value$) {
    switch (field$) {
    case 0: name = (java.lang.CharSequence)value$; break;
    case 1: symbol = (java.lang.CharSequence)value$; break;
    case 2: definition = (java.lang.CharSequence)value$; break;
    default: throw new org.apache.avro.AvroRuntimeException("Bad index");
    }
  }

  /**
   * Gets the value of the 'name' field.
   * @return String representation of the Unit of Measurement
   */
  public java.lang.CharSequence getName() {
    return name;
  }

  /**
   * Sets the value of the 'name' field.
   * String representation of the Unit of Measurement
   * @param value the value to set.
   */
  public void setName(java.lang.CharSequence value) {
    this.name = value;
  }

  /**
   * Gets the value of the 'symbol' field.
   * @return Symbol of the Unit of Measurement
   */
  public java.lang.CharSequence getSymbol() {
    return symbol;
  }

  /**
   * Sets the value of the 'symbol' field.
   * Symbol of the Unit of Measurement
   * @param value the value to set.
   */
  public void setSymbol(java.lang.CharSequence value) {
    this.symbol = value;
  }

  /**
   * Gets the value of the 'definition' field.
   * @return Definition of the Unit of Measurement
   */
  public java.lang.CharSequence getDefinition() {
    return definition;
  }

  /**
   * Sets the value of the 'definition' field.
   * Definition of the Unit of Measurement
   * @param value the value to set.
   */
  public void setDefinition(java.lang.CharSequence value) {
    this.definition = value;
  }

  /**
   * Creates a new UnitOfMeasurement RecordBuilder.
   * @return A new UnitOfMeasurement RecordBuilder
   */
  public static pw.oliver.jmkb.avroclasses.UnitOfMeasurement.Builder newBuilder() {
    return new pw.oliver.jmkb.avroclasses.UnitOfMeasurement.Builder();
  }

  /**
   * Creates a new UnitOfMeasurement RecordBuilder by copying an existing Builder.
   * @param other The existing builder to copy.
   * @return A new UnitOfMeasurement RecordBuilder
   */
  public static pw.oliver.jmkb.avroclasses.UnitOfMeasurement.Builder newBuilder(pw.oliver.jmkb.avroclasses.UnitOfMeasurement.Builder other) {
    return new pw.oliver.jmkb.avroclasses.UnitOfMeasurement.Builder(other);
  }

  /**
   * Creates a new UnitOfMeasurement RecordBuilder by copying an existing UnitOfMeasurement instance.
   * @param other The existing instance to copy.
   * @return A new UnitOfMeasurement RecordBuilder
   */
  public static pw.oliver.jmkb.avroclasses.UnitOfMeasurement.Builder newBuilder(pw.oliver.jmkb.avroclasses.UnitOfMeasurement other) {
    return new pw.oliver.jmkb.avroclasses.UnitOfMeasurement.Builder(other);
  }

  /**
   * RecordBuilder for UnitOfMeasurement instances.
   */
  public static class Builder extends org.apache.avro.specific.SpecificRecordBuilderBase<UnitOfMeasurement>
    implements org.apache.avro.data.RecordBuilder<UnitOfMeasurement> {

    /** String representation of the Unit of Measurement */
    private java.lang.CharSequence name;
    /** Symbol of the Unit of Measurement */
    private java.lang.CharSequence symbol;
    /** Definition of the Unit of Measurement */
    private java.lang.CharSequence definition;

    /** Creates a new Builder */
    private Builder() {
      super(SCHEMA$);
    }

    /**
     * Creates a Builder by copying an existing Builder.
     * @param other The existing Builder to copy.
     */
    private Builder(pw.oliver.jmkb.avroclasses.UnitOfMeasurement.Builder other) {
      super(other);
      if (isValidValue(fields()[0], other.name)) {
        this.name = data().deepCopy(fields()[0].schema(), other.name);
        fieldSetFlags()[0] = true;
      }
      if (isValidValue(fields()[1], other.symbol)) {
        this.symbol = data().deepCopy(fields()[1].schema(), other.symbol);
        fieldSetFlags()[1] = true;
      }
      if (isValidValue(fields()[2], other.definition)) {
        this.definition = data().deepCopy(fields()[2].schema(), other.definition);
        fieldSetFlags()[2] = true;
      }
    }

    /**
     * Creates a Builder by copying an existing UnitOfMeasurement instance
     * @param other The existing instance to copy.
     */
    private Builder(pw.oliver.jmkb.avroclasses.UnitOfMeasurement other) {
            super(SCHEMA$);
      if (isValidValue(fields()[0], other.name)) {
        this.name = data().deepCopy(fields()[0].schema(), other.name);
        fieldSetFlags()[0] = true;
      }
      if (isValidValue(fields()[1], other.symbol)) {
        this.symbol = data().deepCopy(fields()[1].schema(), other.symbol);
        fieldSetFlags()[1] = true;
      }
      if (isValidValue(fields()[2], other.definition)) {
        this.definition = data().deepCopy(fields()[2].schema(), other.definition);
        fieldSetFlags()[2] = true;
      }
    }

    /**
      * Gets the value of the 'name' field.
      * String representation of the Unit of Measurement
      * @return The value.
      */
    public java.lang.CharSequence getName() {
      return name;
    }

    /**
      * Sets the value of the 'name' field.
      * String representation of the Unit of Measurement
      * @param value The value of 'name'.
      * @return This builder.
      */
    public pw.oliver.jmkb.avroclasses.UnitOfMeasurement.Builder setName(java.lang.CharSequence value) {
      validate(fields()[0], value);
      this.name = value;
      fieldSetFlags()[0] = true;
      return this;
    }

    /**
      * Checks whether the 'name' field has been set.
      * String representation of the Unit of Measurement
      * @return True if the 'name' field has been set, false otherwise.
      */
    public boolean hasName() {
      return fieldSetFlags()[0];
    }


    /**
      * Clears the value of the 'name' field.
      * String representation of the Unit of Measurement
      * @return This builder.
      */
    public pw.oliver.jmkb.avroclasses.UnitOfMeasurement.Builder clearName() {
      name = null;
      fieldSetFlags()[0] = false;
      return this;
    }

    /**
      * Gets the value of the 'symbol' field.
      * Symbol of the Unit of Measurement
      * @return The value.
      */
    public java.lang.CharSequence getSymbol() {
      return symbol;
    }

    /**
      * Sets the value of the 'symbol' field.
      * Symbol of the Unit of Measurement
      * @param value The value of 'symbol'.
      * @return This builder.
      */
    public pw.oliver.jmkb.avroclasses.UnitOfMeasurement.Builder setSymbol(java.lang.CharSequence value) {
      validate(fields()[1], value);
      this.symbol = value;
      fieldSetFlags()[1] = true;
      return this;
    }

    /**
      * Checks whether the 'symbol' field has been set.
      * Symbol of the Unit of Measurement
      * @return True if the 'symbol' field has been set, false otherwise.
      */
    public boolean hasSymbol() {
      return fieldSetFlags()[1];
    }


    /**
      * Clears the value of the 'symbol' field.
      * Symbol of the Unit of Measurement
      * @return This builder.
      */
    public pw.oliver.jmkb.avroclasses.UnitOfMeasurement.Builder clearSymbol() {
      symbol = null;
      fieldSetFlags()[1] = false;
      return this;
    }

    /**
      * Gets the value of the 'definition' field.
      * Definition of the Unit of Measurement
      * @return The value.
      */
    public java.lang.CharSequence getDefinition() {
      return definition;
    }

    /**
      * Sets the value of the 'definition' field.
      * Definition of the Unit of Measurement
      * @param value The value of 'definition'.
      * @return This builder.
      */
    public pw.oliver.jmkb.avroclasses.UnitOfMeasurement.Builder setDefinition(java.lang.CharSequence value) {
      validate(fields()[2], value);
      this.definition = value;
      fieldSetFlags()[2] = true;
      return this;
    }

    /**
      * Checks whether the 'definition' field has been set.
      * Definition of the Unit of Measurement
      * @return True if the 'definition' field has been set, false otherwise.
      */
    public boolean hasDefinition() {
      return fieldSetFlags()[2];
    }


    /**
      * Clears the value of the 'definition' field.
      * Definition of the Unit of Measurement
      * @return This builder.
      */
    public pw.oliver.jmkb.avroclasses.UnitOfMeasurement.Builder clearDefinition() {
      definition = null;
      fieldSetFlags()[2] = false;
      return this;
    }

    @Override
    @SuppressWarnings("unchecked")
    public UnitOfMeasurement build() {
      try {
        UnitOfMeasurement record = new UnitOfMeasurement();
        record.name = fieldSetFlags()[0] ? this.name : (java.lang.CharSequence) defaultValue(fields()[0]);
        record.symbol = fieldSetFlags()[1] ? this.symbol : (java.lang.CharSequence) defaultValue(fields()[1]);
        record.definition = fieldSetFlags()[2] ? this.definition : (java.lang.CharSequence) defaultValue(fields()[2]);
        return record;
      } catch (java.lang.Exception e) {
        throw new org.apache.avro.AvroRuntimeException(e);
      }
    }
  }

  @SuppressWarnings("unchecked")
  private static final org.apache.avro.io.DatumWriter<UnitOfMeasurement>
    WRITER$ = (org.apache.avro.io.DatumWriter<UnitOfMeasurement>)MODEL$.createDatumWriter(SCHEMA$);

  @Override public void writeExternal(java.io.ObjectOutput out)
    throws java.io.IOException {
    WRITER$.write(this, SpecificData.getEncoder(out));
  }

  @SuppressWarnings("unchecked")
  private static final org.apache.avro.io.DatumReader<UnitOfMeasurement>
    READER$ = (org.apache.avro.io.DatumReader<UnitOfMeasurement>)MODEL$.createDatumReader(SCHEMA$);

  @Override public void readExternal(java.io.ObjectInput in)
    throws java.io.IOException {
    READER$.read(this, SpecificData.getDecoder(in));
  }

}
