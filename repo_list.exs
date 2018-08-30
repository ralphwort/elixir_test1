repository_list_file_name = Enum.at(System.argv, 0)
github_user = Enum.at(System.argv, 1)
owner = "Payzone-UK"

defmodule GitHub do
  def connect(github_user, github_password) do
    Tentacat.Client.new(%{user: github_user, password: github_password})
  end

  def get_name(github_user, github_password) do
    client = Tentacat.Client.new(%{user: github_user, password: github_password})
    repository_list = Tentacat.Repositories.list_mine(client)
    Enum.each repository_list, fn repository ->
      IO.inspect repository["name"]
    end
  end

  def get_latest_commit(client, owner, repository, branch) do
    cond do
      String.length(repository) > 4 ->
        {200, data, _response} = Tentacat.Repositories.Branches.find(client, owner, repository, branch)
        get_in(get_in(data, ["commit"]), ["sha"])
      true ->
        ""
    end
  end
end

defmodule RepositoryList do
  def list(repository_list_file_name) do
    {:ok, file_contents} = File.read(repository_list_file_name)
    String.split(file_contents, "\n")
  end
end

github_password = String.replace(IO.gets("github_password for {github_user}? "), "\n", "")
client = GitHub.connect(github_user, github_password)
Enum.each RepositoryList.list(repository_list_file_name), fn repository_name ->
  cond do
    String.length(repository_name) > 4 ->
      latest_master_commit = GitHub.get_latest_commit client, owner, repository_name, "master"
      latest_develop_commit = GitHub.get_latest_commit client, owner, repository_name, "develop"
      IO.puts [repository_name, ' master: ', latest_master_commit, ' develop: ', latest_develop_commit]
    true ->
      ""
  end
end

# GitHub.get_name(github_user, github_password)
