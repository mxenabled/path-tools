package com.mx;

import spock.lang.Specification

class MainTest extends Specification {
  def "test hello"() {
    when:
    String cyphertext = "hello"

    then:
    cyphertext.contains "llo"
  }
}
