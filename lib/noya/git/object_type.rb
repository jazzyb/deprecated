module Noya::Git
  ObjectType = {
    0 => 'unknown',
    1 => 'commit',
    2 => 'tree',
    3 => 'blob',
    4 => 'tag',
    5 => 'undefined',
    6 => 'ofs-delta',
    7 => 'ref-delta'
  }
end
