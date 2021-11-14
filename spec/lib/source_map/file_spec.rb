require 'support/source_map_helper'

RSpec.describe Opal::SourceMap::File do
  include SourceMapHelper

  specify '#as_json' do
    map = described_class.new([fragment(code: "foo")], 'foo.rb', "foo")
    expect(map.as_json).to be_a(Hash)
    expect(map.as_json(ignored: :options)).to be_a(Hash)
  end

  it 'correctly map generated code to original positions' do
    fragments = [
      # It doesn't matter too much to keep these fragments updated in terms of generated code,
      # as long as it works as real-world usage.
      fragment(line: nil, column: nil, source_map_name: nil, code: "/* Generated by Opal 0.11.1.dev */", sexp_type: :top),
      fragment(line: nil, column: nil, source_map_name: nil, code: "\n", sexp_type: :top),
      fragment(line: nil, column: nil, source_map_name: nil, code: "(function(Opal) {", sexp_type: :top),
      fragment(line: nil, column: nil, source_map_name: nil, code: "\n  ", sexp_type: :top),
      fragment(line: nil, column: nil, source_map_name: nil, code: "var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.$$$, $$ = Opal.$$, $breaker = Opal.breaker, $slice = Opal.slice;\n", sexp_type: :top),
      fragment(line: nil, column: nil, source_map_name: nil, code: "\n  ", sexp_type: :top),
      fragment(line: nil, column: nil, source_map_name: nil, code: "Opal.add_stubs('puts');", sexp_type: :top),
      fragment(line: nil, column: nil, source_map_name: nil, code: "\n  ", sexp_type: :top),
      fragment(line: 1, column: 0, source_map_name: nil, code: "\n  ", sexp_type: :begin),
      fragment(line: nil, column: nil, source_map_name: "self", code: "self", sexp_type: :self),
      fragment(line: 1, column: 0, source_map_name: :puts, code: ".$puts", sexp_type: :send),
      fragment(line: 1, column: 0, source_map_name: :puts, code: "(", sexp_type: :send),
      fragment(line: 1, column: 5, source_map_name: "5", code: "5", sexp_type: :int),
      fragment(line: 1, column: 0, source_map_name: :puts, code: ")", sexp_type: :send),
      fragment(line: 1, column: 0, source_map_name: nil, code: ";", sexp_type: :begin),
      fragment(line: 1, column: 0, source_map_name: nil, code: "\n  ", sexp_type: :begin),
      fragment(line: 3, column: 0, source_map_name: nil, code: "return ", sexp_type: :js_return),
      fragment(line: nil, column: nil, source_map_name: "self", code: "self", sexp_type: :self),
      fragment(line: 3, column: 0, source_map_name: :puts, code: ".$puts", sexp_type: :send),
      fragment(line: 3, column: 0, source_map_name: :puts, code: "(", sexp_type: :send),
      fragment(line: 3, column: 5, source_map_name: "6", code: "6", sexp_type: :int),
      fragment(line: 3, column: 0, source_map_name: :puts, code: ")", sexp_type: :send),
      fragment(line: 1, column: 0, source_map_name: nil, code: ";", sexp_type: :begin),
      fragment(line: nil, column: nil, source_map_name: nil, code: "\n", sexp_type: :top),
      fragment(line: nil, column: nil, source_map_name: nil, code: "})(Opal);\n", sexp_type: :top),
      fragment(line: nil, column: nil, source_map_name: nil, code: "\n", sexp_type: :newline),
    ]

    subject = described_class.new(fragments, 'foo.rb', "puts 5\n\nputs 6")
    generated_code = subject.generated_code

    expect(subject.map.merge(mappings: nil)).to eq(
      version: 3,
      sourceRoot: '',
      sources: ['foo.rb'],
      sourcesContent: ["puts 5\n\nputs 6"],
      names: ['self', 'puts', '5', '6'],
      mappings: nil,
    )

    expect('$puts(5)').to be_at_line_and_column(6, 7, source: generated_code)
    expect('$puts(5)').to be_at_line_and_column(6, 7, source: generated_code)
    expect('5'       ).to be_at_line_and_column(6, 13, source: generated_code)
    expect('$puts(6)').to be_at_line_and_column(7, 14, source: generated_code)
    expect('6'       ).to be_at_line_and_column(7, 20, source: generated_code)

    expect('puts(5)').to be_mapped_to_line_and_column(0, 0, map: subject, source: generated_code, file: 'foo.rb')
    expect('5);'    ).to be_mapped_to_line_and_column(0, 5, map: subject, source: generated_code, file: 'foo.rb')
    expect('puts(6)').to be_mapped_to_line_and_column(2, 0, map: subject, source: generated_code, file: 'foo.rb')
    expect('6);'    ).to be_mapped_to_line_and_column(2, 5, map: subject, source: generated_code, file: 'foo.rb')
  end
end
