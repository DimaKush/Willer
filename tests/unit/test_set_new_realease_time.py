

def test_set_new_release_time(testator, willer_contract, delay):
    new_release_time = willer_contract.getReleaseTime(testator) + delay
    willer_contract.setNewReleaseTime(new_release_time, {'from': testator})
    assert willer_contract.getReleaseTime(testator) == new_release_time