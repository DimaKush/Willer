

def test_set_new_release_time(add_will, testator, willer_contract, delay):
    new_release_time = willer_contract.getReleaseTime(testator) + willer_contract.getBuffer() + delay
    willer_contract.setNewReleaseTime(new_release_time, {'from': testator})
    assert willer_contract.getReleaseTime(testator) == new_release_time