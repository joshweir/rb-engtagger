# Code Generated by ZenTest v. 3.9.2
#                 classname: asrt / meth =  ratio%
#                    EngTagger:    0 /   24 =   0.00%

$ENGTAGGER_LIB = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << $ENGTAGGER_LIB
require 'test/unit' unless defined? $ZENTEST and $ZENTEST
require 'engtagger'

# copy the private methods into public methods beginning with `t_`
class EngTagger
  %i[classify_unknown_word clean_word get_max_noun_regex reset
    split_punct split_sentences strip_tags valid_text].each do |method|
    define_method "t_#{method}".to_sym, instance_method(method)
  end
end

class TestEngTagger < Test::Unit::TestCase

  @@untagged =<<EOD
Lisa Raines, a lawyer and director of government relations for the Industrial Biotechnical Association, contends that a judge well-versed in patent law and the concerns of research-based industries would have ruled otherwise. And Judge Newman, a former patent lawyer, wrote in her dissent when the court denied a motion for a rehearing of the case by the full court, "The panel's judicial legislation has affected an important high-technological industry, without regard to the consequences for research and innovation or the public interest." Says Ms. Raines, "[The judgement] confirms our concern that the absence of patent lawyers on the court could prove troublesome."
EOD

  @@tagged =<<EOD
<nnp>Lisa</nnp> <nnp>Raines</nnp> <ppc>,</ppc> <det>a</det> <nn>lawyer</nn> <cc>and</cc> <nn>director</nn> <in>of</in> <nn>government</nn> <nns>relations</nns> <in>for</in> <det>the</det> <nnp>Industrial</nnp> <nnp>Biotechnical</nnp> <nnp>Association</nnp> <ppc>,</ppc> <vbz>contends</vbz> <in>that</in> <det>a</det> <nn>judge</nn> <jj>well-versed</jj> <in>in</in> <nn>patent</nn> <nn>law</nn> <cc>and</cc> <det>the</det> <nns>concerns</nns> <in>of</in> <jj>research-based</jj> <nns>industries</nns> <md>would</md> <vb>have</vb> <vbn>ruled</vbn> <rb>otherwise</rb> <pp>.</pp>
EOD

  def setup
    @tagger = EngTagger.new
    tagpath = File.join($ENGTAGGER_LIB, @tagger.conf[:tag_path])
    wordpath = File.join($ENGTAGGER_LIB, @tagger.conf[:word_path])
    if !File.exists?(tagpath) or !File.exists?(wordpath)
      @tagger.install
    end
  end

  def text_get_ext
    model = '<cd>[^<]+</cd}>\s*'
    assert_equal(model, EngTagger.get_ext(model, "cd"))
  end

  def test_explain_tag
    assert_equal("noun", EngTagger.explain_tag("nn"))
    assert_equal("verb_infinitive", EngTagger.explain_tag("vb"))
  end

  def test_add_tags
    assert_instance_of(String, @tagger.add_tags(@@untagged))
  end

  def test_assign_tag
    models = []; tests = []
    models += [@tagger.conf[:unknown_word_tag], "sym"]
    tests += [["pp","-unknown-"], ["pp", "-sym-"]]
    models.length.times do |i|
      assert_equal(models[i],@tagger.assign_tag(*tests[i]))
    end
    tests = []
    tests += [["vb","water"], ["nn", "runs"]]
    models.length.times do |i|
      result = @tagger.assign_tag(*tests[i])
      assert(EngTagger.hmm.keys.index(result))
    end
  end

  def test_classify_unknown_word
    assert_equal("*LRB*", @tagger.t_classify_unknown_word("{"))
    assert_equal("*NUM*", @tagger.t_classify_unknown_word("123.4567"))
    assert_equal("*ORD*", @tagger.t_classify_unknown_word("40th"))
    assert_equal("-abr-", @tagger.t_classify_unknown_word("GT-R"))
    assert_equal("-hyp-adj-", @tagger.t_classify_unknown_word("extremely-high"))
    assert_equal("-sym-", @tagger.t_classify_unknown_word("&&"))
    assert_equal("-ing-", @tagger.t_classify_unknown_word("wikiing"))
    assert_equal("-unknown-", @tagger.t_classify_unknown_word("asefasdf"))
  end

  def test_clean_text
    test = "<html><body>I am <b>100% sure</b> that Dr. Watson is too naive. I'm sorry.</body></html>"
    model = ["I","am","100","%","sure","that","Dr.","Watson","is","too","naive",".","I","'m","sorry","."]
    assert_equal(model, @tagger.clean_text(test)) unless $no_hpricot
  end

  def test_clean_word
    models = []; tests = []
    models += ["*NUM*"]
    models += ["Plays"]
    models += ["pleadingly"]
    tests += ["1973.0820", "Plays", "Pleadingly"]
    models.length.times do |i|
      assert_equal(models[i], @tagger.t_clean_word(tests[i]))
    end
  end

  def test_get_max_noun_phrases
    result = @tagger.get_max_noun_phrases(@@tagged)
    assert_instance_of(Hash, result)
  end

  def test_get_max_noun_regex
    assert_instance_of(Regexp, @tagger.t_get_max_noun_regex)
  end

  def test_get_noun_phrases
    result = @tagger.get_noun_phrases(@@tagged)
    assert_instance_of(Hash, result)
  end

  def test_get_nouns
    result = @tagger.get_nouns(@@tagged)
    assert_instance_of(Hash, result)
  end

  def test_get_verbs
    expected_result = { "have" => 1, "ruled" => 1, "contends" => 1 }
    result = @tagger.get_verbs(@@tagged)
    assert_equal(expected_result, result)
  end

  def test_get_adverbs
    expected_result = { "otherwise" => 1 }
    result = @tagger.get_adverbs(@@tagged)
    assert_equal(expected_result, result)
  end

  def test_get_interrogatives
    tagged = "<wdt>Which</wdt> <ppc>,</ppc> <wdt>whatever</wdt> <ppc>,</ppc> <wp>who</wp> <ppc>,</ppc> <wp>whoever</wp> <ppc>,</ppc> <wrb>when</wrb> <cc>and</cc> <wrb>how</wrb> <vbp>are</vbp> <det>all</det> <nns>examples</nns> <in>of</in> <nns>interrogatives</nns>"
    expected_result = {"when"=>1, "how"=>1, "Which"=>1, "whatever"=>1, "who"=>1, "whoever"=>1}
    result = @tagger.get_interrogatives(tagged)
    assert_equal(expected_result, result)
  end

  def test_get_question_parts
    tagged = "<wdt>Which</wdt> <ppc>,</ppc> <wdt>whatever</wdt> <ppc>,</ppc> <wp>who</wp> <ppc>,</ppc> <wp>whoever</wp> <ppc>,</ppc> <wrb>when</wrb> <cc>and</cc> <wrb>how</wrb> <vbp>are</vbp> <det>all</det> <nns>examples</nns> <in>of</in> <nns>interrogatives</nns>"
    expected_result = {"when"=>1, "how"=>1, "Which"=>1, "whatever"=>1, "who"=>1, "whoever"=>1}
    result = @tagger.get_question_parts(tagged)
    assert_equal(expected_result, result)
  end

  def test_get_conjunctions
    expected_result = { "and" => 2, "of" => 2, "for" => 1, "that" => 1, "in" => 1 }
    result = @tagger.get_conjunctions(@@tagged)
    assert_equal(expected_result, result)
  end

  def test_get_proper_nouns
    test = "<nnp>BBC</nnp> <vbz>means</vbz> <nnp>British Broadcasting Corporation</nnp> <pp>.</pp>"
    result = @tagger.get_proper_nouns(test)
    assert_instance_of(Hash, result)
  end

  def test_get_readable
    test = "I woke up to the sound of pouring rain."
    result = @tagger.get_readable(test)
    assert(String, result)
  end

  def test_get_sentences
    result = @tagger.get_sentences(@@untagged)
    assert_equal(4, result.length)
  end

  def test_get_words
    @tagger.conf[:longest_noun_phrase] = 1
    result1 = @tagger.get_words(@@tagged)
    @tagger.conf[:longest_noun_phrase] = 10
    result2 = @tagger.get_words(@@tagged)
    assert_instance_of(Hash, result1)
    assert_instance_of(Hash, result2)
  end

  def test_reset
    @tagger.conf[:current_tag] = 'nn'
    @tagger.t_reset
    assert_equal('pp', @tagger.conf[:current_tag])
  end

  def test_split_punct
    models = []; texts = []
    models << ["`", "test"]; texts <<  "`test"
    models << ["``", "test"]; texts <<  "\"test"
    models << ["`", "test"]; texts <<  "'test"
    models << ["''"]; texts <<  '"'
    models << ["test", "'"]; texts <<  "test' "
    models << ["-", "test", "-"]; texts << "---test-----"
    models << ["test", ",", "test"]; texts <<  "test,test"
    models << ["123,456"]; texts <<  "123,456"
    models << ["test", ":"]; texts <<  "test:"
    models << ["test1", "...", "test2"]; texts <<  "test1...test2"
    models << ["{", "ab","[","(","c",")","[","d","]","]","}"]; texts <<  "{ab[(c)[d]]}"
    models << ["test", "#", "test"]; texts <<  "test#test"
    models << ["I", "'d", "like"]; texts <<  "I'd like"
    models << ["is", "n't", "so"]; texts <<  "isn't so"
    models << ["we", "'re", "all"]; texts <<  "we're all"

    texts.each_with_index do |text, index|
      assert_equal(models[index], @tagger.t_split_punct(text))
    end
  end

  def test_split_sentences
    models = []; tests = []
    models << ["He", "is", "a", "u.s.", "army", "officer", "."]
    tests << ["He", "is", "a", "u.s.", "army", "officer."]
    models << ["He", "is", "Mr.", "Johnson", ".", "He", "'s", "my", "friend", "."]
    tests << ["He", "is", "Mr.", "Johnson.", "He", "'s", "my", "friend."]
    models.length.times do |i|
      assert_equal(models[i], @tagger.t_split_sentences(tests[i]))
    end
  end

  def test_stem
    word = "gets"
    old = @tagger.conf[:stem]
    @tagger.conf[:stem] = true
    assert_equal("get", @tagger.stem(word))
    # the following should not work since we memoize stem method
    # @tagger.conf[:stem] = false
    # assert_equal("gets", @tagger.stem(word))
    @tagger.conf[:stem] = old
  end

  def test_strip_tags
    assert_instance_of(String, @tagger.t_strip_tags(@@tagged))
  end

  def test_valid_text
    text = nil
    assert(!@tagger.t_valid_text(text))
    text = "this is test text"
    assert(@tagger.t_valid_text(text))
    text = ""
    assert(!@tagger.t_valid_text(text))
  end
  def test_override_default_params
    @tagger = EngTagger.new(:longest_noun_phrase => 3)
    assert_equal 3, @tagger.conf[:longest_noun_phrase]
  end
end

# Number of errors detected: 24
