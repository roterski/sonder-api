defmodule SonderApiWeb.PartyController do
  use SonderApiWeb, :controller

  alias SonderApi.Parties
  alias SonderApi.Parties.Party
  alias SonderApi.Parties.UserParty

  action_fallback SonderApiWeb.FallbackController

  def suggested(conn, _params) do
    parties = Parties.list_suggested_parties(conn.assigns[:current_user].id)
    render(conn, "index.json", parties: parties)
  end

  def accepted(conn, _params) do
    parties = Parties.list_accepted_parties(conn.assigns[:current_user].id)
    render(conn, "index.json", parties: parties)
  end

  def applicants(conn, %{"id" => party_id}) do
    with party <- Parties.get_user_party(%{user_id: conn.assigns[:current_user].id, party_id: party_id}),
        "accepted" <- party.state
    do
      applicants = Parties.list_applicants(party_id)
      render(conn, "people.json", people: applicants)
    end
  end

  def apply(conn, %{"id" => party_id}) do
    with {:ok, %UserParty{}} <- Parties.upsert_user_party(%{user_id: conn.assigns[:current_user].id,
                                                            party_id: party_id,
                                                            state: "applied"})
    do
      send_resp(conn, :no_content, "")
    end
  end

  def dismiss(conn, %{"id" => party_id}) do
    with {:ok, %UserParty{}} <- Parties.upsert_user_party(%{user_id: conn.assigns[:current_user].id,
                                                            party_id: party_id,
                                                            state: "dismissed"})
    do
      send_resp(conn, :no_content, "")
    end
  end

  def create(conn, %{"party" => party_params}) do
    with {:ok, %Party{} = party} <- Parties.create_party(party_params),
         {:ok, %UserParty{}} <- Parties.upsert_user_party(%{user_id: conn.assigns[:current_user].id,
                                                            party_id: party.id,
                                                            state: "accepted"})
    do
      conn
      |> put_status(:created)
      |> render("show.json", party: party)
    end
  end

  # def show(conn, %{"id" => id}) do
  #   party = Parties.get_party!(id)
  #   render(conn, "show.json", party: party)
  # end

  # def update(conn, %{"id" => id, "party" => party_params}) do
  #   party = Parties.get_party!(id)

  #   with {:ok, %Party{} = party} <- Parties.update_party(party, party_params) do
  #     render(conn, "show.json", party: party)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   party = Parties.get_party!(id)
  #   with {:ok, %Party{}} <- Parties.delete_party(party) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
