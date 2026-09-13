from app.services.map_service import _transit_candidate


def test_transit_candidate_expands_intercity_train_and_subway_steps():
    payload = {
        "route": {"transits": [{
            "cost": {"duration": "96240", "transit_fee": "279"},
            "distance": "1735359",
            "walking_distance": "646",
            "segments": [
                {
                    "taxi": {"startname": "桂林", "endname": "桂林北", "drivetime": "2400", "distance": "22715"},
                    "railway": {
                        "name": "K1558(南宁-上海)", "trip": "K1558", "type": "K字头的快车火车", "time": "90720", "distance": "1709278",
                        "departure_stop": {"name": "桂林北"}, "arrival_stop": {"name": "上海"},
                    },
                },
                {"bus": {"buslines": [{
                    "name": "地铁1号线(富锦路--莘庄)", "type": "地铁线路", "distance": "2720", "cost": {"duration": "660"}, "via_num": "2",
                    "departure_stop": {"name": "上海火车站"}, "arrival_stop": {"name": "人民广场"},
                }]}},
                {"walking": {"distance": "646", "cost": {"duration": "701"}}},
            ],
        }]},
    }

    candidate = _transit_candidate(payload, "桂林", "上海")

    assert candidate is not None
    assert [segment["mode"] for segment in candidate["segments"]] == ["网约车", "火车", "地铁", "步行"]
    assert candidate["segments"][1]["from"] == "桂林北"
    assert candidate["segments"][1]["to"] == "上海"
    assert candidate["segments"][-1]["to"] == "上海"
    assert candidate["transfer_count"] == 1
    assert sum(segment["cost"] for segment in candidate["segments"]) == 279
