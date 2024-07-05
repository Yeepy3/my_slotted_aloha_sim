%% slotted aloha function
function [success_rate] = test_slotted_aloha(numNodes, numSlots, transmission_prob)

    % Initialize array
    success_state = zeros(numNodes,numSlots); % 최종 성공 상태를 마킹하기 위한 2d array
    transmission_state = zeros(numNodes,numSlots); % 모든 전송 상태를 마킹하기 위한 2d array
    backoff_timer = zeros(1,numNodes); % 각 node 순서로 backoff timer 기록 저장, 
    collision_state = zeros(1,numNodes); % collision 기록 저장, 한번 collision났을 떄 +1, 이후 backoff 0되면 다시 0으로 state 전환
    attempt_num = zeros(1,numSlots); % 각 slot 당 전송한 횟수 저장

    % Initialize variable
    success_num = 0;

    fprintf('==========================Transmission Probability: %.2f==========================\n', transmission_prob);
    for slot = 1:numSlots
        fprintf('Slot number %d\n', slot);
        % 각 슬롯마다 필요한 배열들 초기화
        node_transmissions_prob = rand(1, numNodes); % 각 노드들의 전송 확률 - 각 슬롯 마다 바뀌도록
        is_transmitting = zeros(1, numNodes);
        % collision = false;

        % decrease 1 time of the backoff timer when the new slot starts
        for i = 1:length(backoff_timer)
            backoff_timer(i) = max(backoff_timer(i) - 1, 0); % 0보다 작아지지 않도록 max 함수 사용
        end
        
        % transmission or not
        for node = 1:numNodes
            if backoff_timer(node) == 0 && collision_state(node) > 0 % 전에 collision 났던 node가 backoff timer가 0으로 돌아온다면
                is_transmitting(node) = 1; %무조건 전송
                collision_state(node) = collision_state(node) - 1; % 해소된 후에는 다시 information을 0으로 되돌리기
                attempt_num(slot) = attempt_num(slot) + 1; % 전송을 시도하는 node들 개수

            elseif backoff_timer(node) == 0 && collision_state(node) == 0 
                if any(node_transmissions_prob(node) < transmission_prob) % 해당 조건에 하나라도 만족하면
                    % transmission
                    is_transmitting(node) = 1; % 해당 노드의 전송임을 저장
                    attempt_num(slot) = attempt_num(slot) + 1; % 전송을 시도하는 node들 개수
                end
            end
        end
        fprintf('Node transmissions: %s\n', sprintf('%d ', is_transmitting));

        % collision
        if sum(is_transmitting) > 1 % 해당 슬롯에서 전송 중인 node가 1개 이상이면 collision
            collision = true;
            all_node = find(is_transmitting == 1); % 전송에 성공한 node를 선택
            transmission_state(all_node,slot) = 1; % 전송이 된 상태의 node와 slot에 마킹
        % success
        elseif sum(is_transmitting) == 1
            collision = false;
            trans_node = find(is_transmitting == 1); % 전송에 성공한 node를 선택
            transmission_state(trans_node,slot) = 1; % 성공한 경우도 보낸거에 추가해야함
            success_state(trans_node,slot) = 1; % 전송이 된 상태의 node와 slot에 마킹
            success_num = success_num + 1;
        % 아무도 전송하지 않은 경우
        else 
            collision = false;
        end

        % collision 발생시 처리방법
        if collision == true
            % collision
            collision_node = find(is_transmitting == 1);
            fprintf('Collision nodes: %s at slot %d\n', sprintf('%d ', collision_node), slot);
            remaining_slots = numSlots - slot;
            % 충돌 시 backoff timer 설정을 위해서 node 정보 저장 필요
            for i = 1:length(collision_node)
                if remaining_slots > 0
                    backoff_timer(collision_node(i)) = randi(remaining_slots); % 남은 slot들 중에서 random으로 backoff time을 배정
                else
                    backoff_timer(collision_node(i)) = 0;
                end
                collision_state(collision_node(i)) = collision_state(collision_node(i)) + 1; % collision 발생 시 해당 노드들의 collision 의미를 저장
            end
            fprintf('Backoff timer: %s\n', sprintf('%d ', backoff_timer));
            
        else 
            % no collision
            fprintf('no collision at slot %d\n',slot);
            % not setting the backoff timer
        end
        fprintf('Backoff-timer at the slot end: %s\n\n', sprintf('%d ', backoff_timer));
    end

    % fprintf('Attempt number: %d\n', sum(attempt_num));
    % fprintf('Success number: %d\n', success_num);
    success_rate = (success_num / sum(attempt_num)) * 100; % output of the function 
    fprintf('Efficiency: %.2f%%\n\n', success_rate);

    % show the transmission state diagram
    figure;
    subplot(2,1,1);
    imagesc(transmission_state);
    xlabel('Slot Time');
    ylabel('Node');
    xticks(0:1:numSlots);
    yticks(0:1:numNodes);

    title('Transmission State');
    colorbar;
    grid on;

    subplot(2,1,2);
    imagesc(success_state);
    xlabel('Slot Time');
    ylabel('Node');
    xticks(0:1:numSlots);
    yticks(0:1:numNodes);
    title('Success State');
    colorbar;
    grid on;
    sgtitle(sprintf('Transmit probability < %.2f', transmission_prob));

end
