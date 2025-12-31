defmodule Auth.RegisterRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :email, 1, type: :string
  field :password, 2, type: :string
end

defmodule Auth.RegisterResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :user_id, 1, type: :string, json_name: "userId"
  field :message, 2, type: :string
end

defmodule Auth.LoginRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :email, 1, type: :string
  field :password, 2, type: :string
end

defmodule Auth.LoginResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :token, 1, type: :string
  field :user_id, 2, type: :string, json_name: "userId"
  field :email, 3, type: :string
end

defmodule Auth.ValidateTokenRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :token, 1, type: :string
end

defmodule Auth.ValidateTokenResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :is_valid, 1, type: :bool, json_name: "isValid"
  field :user_id, 2, type: :string, json_name: "userId"
  field :email, 3, type: :string
end

defmodule Auth.AuthService.Service do
  @moduledoc false

  use GRPC.Service, name: "auth.AuthService", protoc_gen_elixir_version: "0.15.0"

  rpc :Register, Auth.RegisterRequest, Auth.RegisterResponse

  rpc :Login, Auth.LoginRequest, Auth.LoginResponse

  rpc :ValidateToken, Auth.ValidateTokenRequest, Auth.ValidateTokenResponse
end

defmodule Auth.AuthService.Stub do
  @moduledoc false

  use GRPC.Stub, service: Auth.AuthService.Service
end
